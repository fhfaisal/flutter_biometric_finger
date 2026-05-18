/// Represents the hardware characteristics and state of the initialized fingerprint scanner.
class ScannerDevice {
  /// Constructor to initialize a [ScannerDevice] with all its hardware metadata.
  const ScannerDevice({
    required this.found,
    required this.message,
    required this.device,
    required this.type,
    required this.serialNumber,
    required this.model,
    required this.manufacturer,
    required this.product,
    required this.sessionOpen,
    required this.scanWidth,
    required this.scanHeight,
    required this.usbDevices,
    required this.raw,
  });

  /// Factory constructor to parse and map raw JSON or Map responses from the native method channel.
  factory ScannerDevice.fromMap(Map<String, Object?> map) {
    return ScannerDevice(
      found: map['found'] == true,
      message: map['message']?.toString() ?? '',
      device: map['device']?.toString(),
      type: map['type']?.toString(),
      serialNumber: map['serialNumber']?.toString(),
      model: map['model']?.toString(),
      manufacturer: map['manufacturer']?.toString(),
      product: map['product']?.toString(),
      sessionOpen: map['sessionOpen'] == true,
      scanWidth: _asInt(map['scanWidth']),
      scanHeight: _asInt(map['scanHeight']),
      usbDevices: _asUsbDevices(map['usbDevices']),
      raw: map,
    );
  }

  /// Whether a supported scanner was successfully located on the USB host.
  final bool found;

  /// User-friendly initialization message or error description.
  final String message;

  /// The operating system's device identifier/path.
  final String? device;

  /// The sensor/scanner technology type name (e.g. NB65200U).
  final String? type;

  /// The unique hardware serial number of the connected device.
  final String? serialNumber;

  /// The model name of the connected scanner.
  final String? model;

  /// The manufacturer name of the connected scanner.
  final String? manufacturer;

  /// The product name of the connected scanner.
  final String? product;

  /// Whether a live communication session has been opened with the scanner.
  final bool sessionOpen;

  /// The standard scanning resolution width in pixels.
  final int scanWidth;

  /// The standard scanning resolution height in pixels.
  final int scanHeight;

  /// List of raw USB devices detected on the platform's USB host.
  final List<Map<String, Object?>> usbDevices;

  /// The raw unparsed map from the native layer.
  final Map<String, Object?> raw;

  static int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<Map<String, Object?>> _asUsbDevices(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => item.cast<String, Object?>())
        .toList(growable: false);
  }
}
