
import 'package:flutter_biometric_finger/flutter_biometric_finger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plugin exposes scanner object', (tester) async {
    const scanner = FlutterBiomatricFinger();
    expect(scanner, isA<FlutterBiomatricFinger>());
  });
}
