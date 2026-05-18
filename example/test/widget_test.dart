import 'package:flutter_biometric_finger_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example renders scanner actions', (tester) async {
    await tester.pumpWidget(const ScannerExampleApp());

    expect(find.text('Initialize'), findsOneWidget);
    expect(find.text('Scan Finger'), findsOneWidget);
    expect(find.text('Dispose'), findsOneWidget);
  });
}
