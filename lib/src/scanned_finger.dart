import 'dart:typed_data';

/// The raw details of a single scanned finger returned from the device's native platform channel.
class ScannedFinger {
  /// Constructor to initialize a [ScannedFinger] with all its raw biometric details.
  const ScannedFinger({
    required this.status,
    required this.quality,
    required this.templateType,
    required this.templateBase64,
    required this.templateLength,
    required this.scanMillis,
    required this.fingerDetectScore,
    required this.spoofScore,
    required this.imageWidth,
    required this.imageHeight,
    required this.imagePngBytes,
    required this.raw,
  });

  /// Factory constructor to parse and map raw JSON or Map responses from the native method channel.
  factory ScannedFinger.fromMap(Map<String, Object?> map) {
    return ScannedFinger(
      status: map['status']?.toString() ?? '',
      quality: _asInt(map['quality']),
      templateType: map['templateType']?.toString() ?? '',
      templateBase64: map['templateBase64']?.toString() ?? '',
      templateLength: _asInt(map['templateLength']),
      scanMillis: _asInt(map['scanMillis']),
      fingerDetectScore: _asInt(map['fingerDetectScore']),
      spoofScore: _asInt(map['spoofScore']),
      imageWidth: _asInt(map['imageWidth']),
      imageHeight: _asInt(map['imageHeight']),
      imagePngBytes: map['imagePngBytes'] as Uint8List?,
      raw: map,
    );
  }

  /// The raw status string from the scanner (typically "OK" if scan succeeded).
  final String status;

  /// The quality index of the scanned finger image.
  final int quality;

  /// The type format of the returned biometric template.
  final String templateType;

  /// The Base64 representation of the compiled ISO standard biometric fingerprint template.
  final String templateBase64;

  /// The size/length of the template in bytes.
  final int templateLength;

  /// How long the scanning operation took in milliseconds.
  final int scanMillis;

  /// The score representing the system's confidence that a real finger is present on the scanner.
  final int fingerDetectScore;

  /// The spoof protection/liveness score evaluated by the system.
  final int spoofScore;

  /// The width of the returned fingerprint preview image in pixels.
  final int imageWidth;

  /// The height of the returned fingerprint preview image in pixels.
  final int imageHeight;

  /// The binary PNG formatted image bytes of the fingerprint, ready for presentation.
  final Uint8List? imagePngBytes;

  /// The raw unparsed map from the native layer.
  final Map<String, Object?> raw;

  /// Returns true if the status returned from the native layer is successful ("OK").
  bool get isSuccess => status == 'OK';

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
