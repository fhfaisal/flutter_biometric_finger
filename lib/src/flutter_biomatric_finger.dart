import '../flutter_biometric_finger_platform_interface.dart';
import 'scanned_finger.dart';
import 'scanner_device.dart';

class FlutterBiomatricFinger {
  const FlutterBiomatricFinger();

  Future<ScannerDevice> initialize() {
    return FlutterBiomatricFingerPlatform.instance.initialize();
  }

  Future<ScannedFinger> scanAndExtract() {
    return FlutterBiomatricFingerPlatform.instance.scanAndExtract();
  }

  Future<void> dispose() {
    return FlutterBiomatricFingerPlatform.instance.dispose();
  }
}
