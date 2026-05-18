
import 'package:flutter_biometric_finger/flutter_biometric_finger.dart';
import 'package:flutter_biometric_finger/flutter_biometric_finger_method_channel.dart';
import 'package:flutter_biometric_finger/flutter_biometric_finger_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterBiomatricFingerPlatform
    with MockPlatformInterfaceMixin
    implements FlutterBiomatricFingerPlatform {
  @override
  Future<ScannerDevice> initialize() async {
    return const ScannerDevice(
      found: true,
      message: 'Scanner ready.',
      device: null,
      type: 'NB65200U',
      serialNumber: null,
      model: 'AbeTree-ATS-24',
      manufacturer: null,
      product: null,
      sessionOpen: true,
      scanWidth: 300,
      scanHeight: 400,
      usbDevices: [],
      raw: {},
    );
  }

  @override
  Future<ScannedFinger> scanAndExtract() async {
    return const ScannedFinger(
      status: 'OK',
      quality: 80,
      templateType: 'ISO',
      templateBase64: 'abc123',
      templateLength: 6,
      scanMillis: 1200,
      fingerDetectScore: 0,
      spoofScore: 0,
      imageWidth: 300,
      imageHeight: 400,
      imagePngBytes: null,
      raw: {},
    );
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  final initialPlatform = FlutterBiomatricFingerPlatform.instance;

  test('$MethodChannelFlutterBiomatricFinger is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterBiomatricFinger>());
  });

  test('FlutterBiomatricFinger delegates to platform', () async {
    const scanner = FlutterBiomatricFinger();
    FlutterBiomatricFingerPlatform.instance = MockFlutterBiomatricFingerPlatform();

    final device = await scanner.initialize();
    final scan = await scanner.scanAndExtract();
    await scanner.dispose();

    expect(device.found, isTrue);
    expect(scan.isSuccess, isTrue);
  });
}
