import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import 'flutter_biomatric_finger.dart';
import 'finger.dart';
import 'finger_scan_result.dart';
import 'scanner_device.dart';

class ScannerController extends ChangeNotifier {
  ScannerController({List<Finger> fingers = Finger.all, FlutterBiomatricFinger scanner = const FlutterBiomatricFinger()})
    : allowedFingers = List.unmodifiable(fingers),
      _scanner = scanner;

  final List<Finger> allowedFingers;
  final FlutterBiomatricFinger _scanner;

  bool _isBusy = false;
  bool _isInitialized = false;
  String _status = 'Connect the scanner, then tap Initialize.';
  int? _scanningFingerId;
  ScannerDevice? _device;
  final Map<int, FingerScanResult> _results = {};

  bool get isBusy => _isBusy;
  bool get isInitialized => _isInitialized;
  String get status => _status;
  int? get scanningFingerId => _scanningFingerId;
  ScannerDevice? get device => _device;
  Map<int, FingerScanResult> get results => Map.unmodifiable(_results);

  int get scannedCount => _results.length;
  int get totalCount => allowedFingers.length;
  bool get allScanned => scannedCount == totalCount;

  bool isScanned(Finger finger) => _results.containsKey(finger.id);
  bool isScanning(Finger finger) => _scanningFingerId == finger.id;
  FingerScanResult? resultFor(Finger finger) => _results[finger.id];

  Future<ScannerDevice?> initialize() async {
    if (_isBusy) return _device;
    _setBusy(true, 'Initializing scanner...');
    _results.clear();

    try {
      final scannerDevice = await _scanner.initialize();
      _device = scannerDevice;
      _isInitialized = scannerDevice.found;
      _status = scannerDevice.message;
      dev.log('[AbeTree] Initialized: ${scannerDevice.raw}');
      return scannerDevice;
    } catch (error, stackTrace) {
      _isInitialized = false;
      dev.log('[AbeTree] Init error', error: error, stackTrace: stackTrace);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  Future<void> disposeScanner() async {
    if (_isBusy) return;
    _setBusy(true, 'Disposing session...');

    try {
      await _scanner.dispose();
      _device = null;
      _isInitialized = false;
      _results.clear();
      dev.log('[AbeTree] Disposed.');
    } catch (error, stackTrace) {
      dev.log('[AbeTree] Dispose error', error: error, stackTrace: stackTrace);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  void clearResults() {
    _results.clear();
    _status = 'Results cleared.';
    notifyListeners();
  }

  Future<FingerScanResult?> scanFinger(Finger finger) async {
    assert(allowedFingers.contains(finger), '${finger.label} is not in allowedFingers for this controller.');
    if (_isBusy || !_isInitialized) return null;

    _setBusy(true, 'Place your ${finger.label} on the scanner...');
    _scanningFingerId = finger.id;
    notifyListeners();

    try {
      final scan = await _scanner.scanAndExtract();
      final result = FingerScanResult(finger: finger, scan: scan, scannedAt: DateTime.now());
      _results[finger.id] = result;
      _status = '${finger.label} captured.';
      _logResult(result);
      return result;
    } catch (error, stackTrace) {
      dev.log('[AbeTree] Scan error (${finger.label})', error: error, stackTrace: stackTrace);
      rethrow;
    } finally {
      _scanningFingerId = null;
      _setBusy(false);
    }
  }

  void _setBusy(bool value, [String? message]) {
    _isBusy = value;
    if (message != null) _status = message;
    notifyListeners();
  }

  void _logResult(FingerScanResult result) {
    final scan = result.scan;
    final templateHead = scan.templateBase64.substring(0, scan.templateBase64.length.clamp(0, 80));
    dev.log(
      '[AbeTree] ${result.finger.label}\n'
      '  status: ${scan.status}\n'
      '  quality: ${scan.quality}\n'
      '  templateType: ${scan.templateType}\n'
      '  templateLength: ${scan.templateLength} bytes\n'
      '  scanMillis: ${scan.scanMillis} ms\n'
      '  fingerScore: ${scan.fingerDetectScore}\n'
      '  spoofScore: ${scan.spoofScore}\n'
      '  imageSize: ${scan.imageWidth} x ${scan.imageHeight}\n'
      '  base64 head: $templateHead...',
    );
  }
}
