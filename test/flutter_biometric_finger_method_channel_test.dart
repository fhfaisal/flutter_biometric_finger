
import 'package:flutter/services.dart';
import 'package:flutter_biometric_finger/flutter_biometric_finger_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelFlutterBiometricFinger();
  const channel = MethodChannel('flutter_biometric_finger');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('initialize parses scanner device response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'initialize');
          return {
            'found': true,
            'message': 'Scanner detected.',
            'type': 'NB65200U',
            'model': 'AbeTree-ATS-24',
            'scanWidth': 300,
            'scanHeight': 400,
          };
        });

    final device = await platform.initialize();

    expect(device.found, isTrue);
    expect(device.type, 'NB65200U');
    expect(device.scanWidth, 300);
  });

  test('scanAndExtract parses scanned finger response', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'scanAndExtract');
          return {
            'status': 'OK',
            'quality': 80,
            'templateType': 'ISO',
            'templateBase64': 'abc123',
            'templateLength': 6,
            'scanMillis': 1200,
          };
        });

    final scan = await platform.scanAndExtract();

    expect(scan.isSuccess, isTrue);
    expect(scan.quality, 80);
    expect(scan.templateBase64, 'abc123');
  });
}
