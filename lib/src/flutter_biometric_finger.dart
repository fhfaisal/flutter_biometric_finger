import '../flutter_biometric_finger_platform_interface.dart';
import 'scanned_finger.dart';
import 'scanner_device.dart';

/// The main entry point for the `flutter_biometric_finger` plugin.
///
/// Use this class to initialize the fingerprint scanner, capture scans, and release resources.
class FlutterBiometricFinger {
  /// Creates a [FlutterBiometricFinger] instance.
  const FlutterBiometricFinger();

  /// Initializes the fingerprint scanner device and establishes a connection session.
  ///
  /// Returns a [ScannerDevice] containing metadata about the connected scanner.
  Future<ScannerDevice> initialize() {
    return FlutterBiometricFingerPlatform.instance.initialize();
  }

  /// Prompts the user to place their finger on the scanner, captures the print,
  /// and extracts standard fingerprint template data.
  ///
  /// Returns a [ScannedFinger] with quality assessment and Base64 template strings.
  Future<ScannedFinger> scanAndExtract() {
    return FlutterBiometricFingerPlatform.instance.scanAndExtract();
  }

  /// Closes the communication session with the fingerprint scanner and frees resources.
  Future<void> dispose() {
    return FlutterBiometricFingerPlatform.instance.dispose();
  }
}
