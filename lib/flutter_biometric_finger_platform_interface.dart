import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_biometric_finger_method_channel.dart';
import 'src/scanned_finger.dart';
import 'src/scanner_device.dart';

abstract class FlutterBiomatricFingerPlatform extends PlatformInterface {
  FlutterBiomatricFingerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterBiomatricFingerPlatform _instance = MethodChannelFlutterBiomatricFinger();

  static FlutterBiomatricFingerPlatform get instance => _instance;

  static set instance(FlutterBiomatricFingerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<ScannerDevice> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<ScannedFinger> scanAndExtract() {
    throw UnimplementedError('scanAndExtract() has not been implemented.');
  }

  Future<void> dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}
