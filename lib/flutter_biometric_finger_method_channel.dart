import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_biometric_finger_platform_interface.dart';
import 'src/scanned_finger.dart';
import 'src/scanner_device.dart';

class MethodChannelFlutterBiomatricFinger extends FlutterBiomatricFingerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_biomatric_finger');

  @override
  Future<ScannerDevice> initialize() async {
    final response = await methodChannel.invokeMapMethod<String, Object?>(
      'initialize',
    );
    return ScannerDevice.fromMap(response ?? const {});
  }

  @override
  Future<ScannedFinger> scanAndExtract() async {
    final response = await methodChannel.invokeMapMethod<String, Object?>(
      'scanAndExtract',
    );
    return ScannedFinger.fromMap(response ?? const {});
  }

  @override
  Future<void> dispose() async {
    await methodChannel.invokeMethod<bool>('dispose');
  }
}
