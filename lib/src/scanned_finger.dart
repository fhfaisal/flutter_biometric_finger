import 'dart:typed_data';

class ScannedFinger {
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

  final String status;
  final int quality;
  final String templateType;
  final String templateBase64;
  final int templateLength;
  final int scanMillis;
  final int fingerDetectScore;
  final int spoofScore;
  final int imageWidth;
  final int imageHeight;
  final Uint8List? imagePngBytes;
  final Map<String, Object?> raw;

  bool get isSuccess => status == 'OK';

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
