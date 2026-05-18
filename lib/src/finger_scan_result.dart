import 'finger.dart';
import 'scanned_finger.dart';

/// Represents the completed result of a single fingerprint scan.
///
/// Contains details about which [finger] was scanned, the raw [scan] data,
/// and metadata such as the timestamp of the scan.
class FingerScanResult {
  /// Creates a new [FingerScanResult] with the provided [finger], [scan] details, and [scannedAt] timestamp.
  const FingerScanResult({
    required this.finger,
    required this.scan,
    required this.scannedAt,
  });

  /// The finger that was scanned.
  final Finger finger;

  /// The raw scanned finger data returned by the native platform.
  final ScannedFinger scan;

  /// The timestamp when the fingerprint was scanned.
  final DateTime scannedAt;

  /// The status of the scan (e.g. "success", "error", or other scanner states).
  String get status => scan.status;

  /// The quality of the scan, typically an integer value representing image quality.
  int get quality => scan.quality;

  /// The standard type format of the extracted template (e.g. ISO-19794-2).
  String get templateType => scan.templateType;

  /// The Base64 encoded representation of the extracted standard fingerprint template.
  String get templateBase64 => scan.templateBase64;

  /// The size of the extracted template in bytes.
  int get templateLength => scan.templateLength;

  /// The time taken to perform the physical scan in milliseconds.
  int get scanMillis => scan.scanMillis;

  /// The finger detection confidence score returned by the device.
  int get fingerDetectScore => scan.fingerDetectScore;

  /// The anti-spoof/liveness detection score of the scanned finger.
  int get spoofScore => scan.spoofScore;

  /// The width of the captured fingerprint image in pixels.
  int get imageWidth => scan.imageWidth;

  /// The height of the captured fingerprint image in pixels.
  int get imageHeight => scan.imageHeight;

  /// Returns true if the scan status is successful.
  bool get isSuccess => scan.isSuccess;

  @override
  String toString() {
    return 'FingerScanResult(${finger.label}, status=$status, '
        'quality=$quality, ${scanMillis}ms, ${templateLength}B)';
  }
}
