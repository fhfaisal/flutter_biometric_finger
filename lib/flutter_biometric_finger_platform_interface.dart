import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_biometric_finger_method_channel.dart';
import 'src/scanned_finger.dart';
import 'src/scanner_device.dart';

/// The common platform interface for `flutter_biometric_finger`.
///
/// Platform-specific implementations must extend this class to provide
/// direct hardware access on Android.
abstract class FlutterBiometricFingerPlatform extends PlatformInterface {
  /// Constructs a [FlutterBiometricFingerPlatform].
  FlutterBiometricFingerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBiometricFingerPlatform _instance = MethodChannelFlutterBiometricFinger();

  /// The default instance of [FlutterBiometricFingerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterBiometricFinger].
  static FlutterBiometricFingerPlatform get instance => _instance;

  /// Sets the active platform-specific implementation instance.
  static set instance(FlutterBiometricFingerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initializes the fingerprint scanner device and establishes a session.
  Future<ScannerDevice> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Captures a fingerprint scan and extracts standard template data.
  Future<ScannedFinger> scanAndExtract() {
    throw UnimplementedError('scanAndExtract() has not been implemented.');
  }

  /// Closes the session and releases the fingerprint scanner resources.
  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
