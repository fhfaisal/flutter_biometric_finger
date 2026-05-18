class ScannerDevice {
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

  final bool found;
  final String message;
  final String? device;
  final String? type;
  final String? serialNumber;
  final String? model;
  final String? manufacturer;
  final String? product;
  final bool sessionOpen;
  final int scanWidth;
  final int scanHeight;
  final List<Map<String, Object?>> usbDevices;
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
