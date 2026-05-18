package com.faisalhasan.flutter_biometric_finger

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Color
import android.hardware.usb.UsbManager
import android.os.Handler
import android.os.Looper
import android.util.Base64
import com.nextbiometrics.biometrics.NBBiometricsContext
import com.nextbiometrics.biometrics.NBBiometricsFingerPosition
import com.nextbiometrics.biometrics.NBBiometricsStatus
import com.nextbiometrics.biometrics.NBBiometricsTemplateType
import com.nextbiometrics.biometrics.event.NBBiometricsScanPreviewEvent
import com.nextbiometrics.biometrics.event.NBBiometricsScanPreviewListener
import com.nextbiometrics.devices.NBDevice
import com.nextbiometrics.devices.NBDeviceScanFormatInfo
import com.nextbiometrics.devices.NBDeviceSecurityModel
import com.nextbiometrics.devices.NBDevices
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream

class FlutterBiometricFingerPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var appContext: Context
    private val mainHandler = Handler(Looper.getMainLooper())

    private var device: NBDevice? = null
    private var scanFormatInfo: NBDeviceScanFormatInfo? = null
    private var initialized = false
    private var scanInProgress = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        appContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> initializeScanner(result)
            "scanAndExtract" -> scanAndExtract(result)
            "dispose" -> disposeScanner(result)
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        cleanup()
    }

    private fun initializeScanner(result: Result) {
        Thread {
            try {
                initializeDeviceBlocking(reset = true)
                val activeDevice = device
                postSuccess(
                    result,
                    mapOf(
                        "found" to true,
                        "message" to "Scanner detected.",
                        "device" to activeDevice.toString(),
                        "type" to activeDevice?.type?.toString(),
                        "serialNumber" to activeDevice?.serialNumber,
                        "model" to activeDevice?.model,
                        "manufacturer" to activeDevice?.manufacturer,
                        "product" to activeDevice?.product,
                        "sessionOpen" to activeDevice?.isSessionOpen,
                        "scanWidth" to scanFormatInfo?.width,
                        "scanHeight" to scanFormatInfo?.height
                    )
                )
            } catch (error: NoDeviceException) {
                postSuccess(
                    result,
                    mapOf(
                        "found" to false,
                        "message" to "No AbeTree scanner found by the SDK.",
                        "usbDevices" to getConnectedUsbDevices()
                    )
                )
            } catch (error: Throwable) {
                postError(result, "ABETREE_INIT_FAILED", error)
            }
        }.start()
    }

    private fun scanAndExtract(result: Result) {
        if (scanInProgress) {
            result.error("ABETREE_SCAN_IN_PROGRESS", "A scan is already running.", null)
            return
        }

        scanInProgress = true
        Thread {
            var context: NBBiometricsContext? = null
            try {
                if (device == null || scanFormatInfo == null) {
                    initializeDeviceBlocking(reset = false)
                }

                val activeDevice = device ?: throw IllegalStateException("Scanner is not initialized.")
                val activeScanFormat = scanFormatInfo ?: throw IllegalStateException("Scan format is not initialized.")

                openSession(activeDevice)
                val previewListener = PreviewCollector()
                context = NBBiometricsContext(activeDevice)

                val startTime = System.currentTimeMillis()
                val extractResult = context.extract(
                    NBBiometricsTemplateType.ISO,
                    NBBiometricsFingerPosition.UNKNOWN,
                    activeScanFormat,
                    previewListener
                )
                val stopTime = System.currentTimeMillis()

                if (extractResult.status != NBBiometricsStatus.OK) {
                    throw IllegalStateException("Extraction failed: ${extractResult.status}")
                }

                val template = extractResult.template
                val templateBytes = context.saveTemplate(template)
                val imagePngBytes = previewListener.lastImage?.let {
                    encodeGrayscalePng(it, activeScanFormat.width, activeScanFormat.height)
                }

                postSuccess(
                    result,
                    mapOf(
                        "status" to extractResult.status.toString(),
                        "quality" to template.quality,
                        "templateType" to template.type.toString(),
                        "templateBase64" to Base64.encodeToString(templateBytes, Base64.NO_WRAP),
                        "templateLength" to templateBytes.size,
                        "scanMillis" to (stopTime - startTime),
                        "fingerDetectScore" to previewListener.fingerDetectScore,
                        "spoofScore" to previewListener.spoofScore,
                        "imageWidth" to activeScanFormat.width,
                        "imageHeight" to activeScanFormat.height,
                        "imageBytes" to previewListener.lastImage,
                        "imagePngBytes" to imagePngBytes
                    )
                )
            } catch (error: Throwable) {
                postError(result, "ABETREE_SCAN_FAILED", error)
            } finally {
                context?.dispose()
                scanInProgress = false
            }
        }.start()
    }

    private fun initializeDeviceBlocking(reset: Boolean) {
        if (reset && initialized) {
            cleanup()
        }

        if (!initialized) {
            NBDevices.initialize(appContext)
            initialized = true
        }

        var devices = NBDevices.getDevices()
        repeat(50) {
            if (devices.isNotEmpty()) return@repeat
            Thread.sleep(500)
            devices = NBDevices.getDevices()
        }

        if (devices.isEmpty()) {
            throw NoDeviceException()
        }

        device = devices.first()
        val activeDevice = device ?: throw NoDeviceException()
        openSession(activeDevice)

        val scanFormats = activeDevice.supportedScanFormats ?: emptyArray()
        if (scanFormats.isEmpty()) {
            throw IllegalStateException("No supported scan formats found.")
        }
        scanFormatInfo = scanFormats.first()
    }

    private fun openSession(activeDevice: NBDevice?) {
        if (activeDevice == null || activeDevice.isSessionOpen) return

        val cakId = "DefaultCAKKey1\u0000".toByteArray()
        val cak = byteArrayOf(
            0x05, 0x4B, 0x38, 0x3A, 0xCF.toByte(), 0x5B, 0xB8.toByte(), 0x01,
            0xDC.toByte(), 0xBB.toByte(), 0x85.toByte(), 0xB4.toByte(), 0x47,
            0xFF.toByte(), 0xF0.toByte(), 0x79, 0x77, 0x90.toByte(),
            0x90.toByte(), 0x81.toByte(), 0x51, 0x42, 0xC1.toByte(),
            0xBF.toByte(), 0xF6.toByte(), 0xD1.toByte(), 0x66, 0x65, 0x0A,
            0x66, 0x34, 0x11
        )
        val cdkId = "Application Lock\u0000".toByteArray()
        val cdk = byteArrayOf(
            0x6B, 0xC5.toByte(), 0x51, 0xD1.toByte(), 0x12, 0xF7.toByte(),
            0xE3.toByte(), 0x42, 0xBD.toByte(), 0xDC.toByte(), 0xFB.toByte(),
            0x5D, 0x79, 0x4E, 0x5A, 0xD6.toByte(), 0x54, 0xD1.toByte(),
            0xC9.toByte(), 0x90.toByte(), 0x28, 0x05, 0xCF.toByte(), 0x5E,
            0x4C, 0x83.toByte(), 0x63, 0xFB.toByte(), 0xC2.toByte(), 0x3C,
            0xF6.toByte(), 0xAB.toByte()
        )
        val defaultAuthKey1Id = "AUTH1\u0000".toByteArray()
        val defaultAuthKey1 = byteArrayOf(
            0xDA.toByte(), 0x2E, 0x35, 0xB6.toByte(), 0xCB.toByte(),
            0x96.toByte(), 0x2B, 0x5F, 0x9F.toByte(), 0x34, 0x1F,
            0xD1.toByte(), 0x47, 0x41, 0xA0.toByte(), 0x4D, 0xA4.toByte(),
            0x09, 0xCE.toByte(), 0xE8.toByte(), 0x35, 0x48, 0x3C, 0x60,
            0xFB.toByte(), 0x13, 0x91.toByte(), 0xE0.toByte(), 0x9E.toByte(),
            0x95.toByte(), 0xB2.toByte(), 0x7F
        )

        when (NBDeviceSecurityModel.get(activeDevice.capabilities.securityModel.toInt())) {
            NBDeviceSecurityModel.Model65200CakOnly -> activeDevice.openSession(cakId, cak)
            NBDeviceSecurityModel.Model65200CakCdk -> {
                try {
                    activeDevice.openSession(cdkId, cdk)
                    activeDevice.SetBlobParameter(NBDevice.BLOB_PARAMETER_SET_CDK, null)
                    activeDevice.closeSession()
                } catch (_: RuntimeException) {
                }
                activeDevice.openSession(cakId, cak)
                activeDevice.SetBlobParameter(NBDevice.BLOB_PARAMETER_SET_CDK, cdk)
                activeDevice.closeSession()
                activeDevice.openSession(cdkId, cdk)
            }
            NBDeviceSecurityModel.Model65100 -> activeDevice.openSession(defaultAuthKey1Id, defaultAuthKey1)
            else -> Unit
        }
    }

    private fun getConnectedUsbDevices(): List<Map<String, Any?>> {
        val usbManager = appContext.getSystemService(Context.USB_SERVICE) as UsbManager
        return usbManager.deviceList.values.map { usbDevice ->
            mapOf(
                "deviceName" to usbDevice.deviceName,
                "vendorId" to usbDevice.vendorId,
                "productId" to usbDevice.productId,
                "manufacturerName" to usbDevice.manufacturerName,
                "productName" to usbDevice.productName,
                "hasPermission" to usbManager.hasPermission(usbDevice)
            )
        }
    }

    private fun encodeGrayscalePng(image: ByteArray, width: Int, height: Int): ByteArray {
        val pixels = IntArray(width * height)
        val limit = minOf(image.size, pixels.size)
        for (index in 0 until limit) {
            val gray = image[index].toInt() and 0xFF
            pixels[index] = Color.argb(255, gray, gray, gray)
        }

        val bitmap = Bitmap.createBitmap(pixels, width, height, Bitmap.Config.ARGB_8888)
        val output = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, output)
        bitmap.recycle()
        return output.toByteArray()
    }

    private fun disposeScanner(result: Result) {
        try {
            cleanup()
            result.success(true)
        } catch (error: Throwable) {
            result.error("ABETREE_DISPOSE_FAILED", error.message, error.toString())
        }
    }

    private fun cleanup() {
        device?.dispose()
        device = null
        scanFormatInfo = null
        if (initialized) {
            NBDevices.terminate()
            initialized = false
        }
    }

    private fun postSuccess(result: Result, value: Any?) {
        mainHandler.post { result.success(value) }
    }

    private fun postError(result: Result, code: String, error: Throwable) {
        mainHandler.post { result.error(code, error.message, error.toString()) }
    }

    private class PreviewCollector : NBBiometricsScanPreviewListener {
        var lastImage: ByteArray? = null
            private set
        var fingerDetectScore = 0
            private set
        var spoofScore = 0
            private set

        override fun preview(event: NBBiometricsScanPreviewEvent) {
            lastImage = event.image ?: lastImage
            fingerDetectScore = event.fingerDetectValue
            spoofScore = event.spoofScoreValue
        }
    }

    private class NoDeviceException : Exception()

    companion object {
        private const val CHANNEL_NAME = "abetree_scanner"
    }
}
