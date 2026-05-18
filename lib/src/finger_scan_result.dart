import 'finger.dart';
import 'scanned_finger.dart';

class FingerScanResult {
  const FingerScanResult({
    required this.finger,
    required this.scan,
    required this.scannedAt,
  });

  final Finger finger;
  final ScannedFinger scan;
  final DateTime scannedAt;

  String get status => scan.status;
  int get quality => scan.quality;
  String get templateType => scan.templateType;
  String get templateBase64 => scan.templateBase64;
  int get templateLength => scan.templateLength;
  int get scanMillis => scan.scanMillis;
  int get fingerDetectScore => scan.fingerDetectScore;
  int get spoofScore => scan.spoofScore;
  int get imageWidth => scan.imageWidth;
  int get imageHeight => scan.imageHeight;
  bool get isSuccess => scan.isSuccess;

  @override
  String toString() {
    return 'FingerScanResult(${finger.label}, status=$status, '
        'quality=$quality, ${scanMillis}ms, ${templateLength}B)';
  }
}
