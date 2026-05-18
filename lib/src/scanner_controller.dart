import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';

import 'flutter_biometric_finger.dart';
import 'finger.dart';
import 'finger_scan_result.dart';
import 'scanner_device.dart';

/// A controller that manages the workflow state, active sessions, and results
/// for biometric enrollment or verification.
///
/// Extends [ChangeNotifier] to broadcast state changes to active listeners/views.
class ScannerController extends ChangeNotifier {
  /// Creates a new [ScannerController] instance.
  ///
  /// Can optionally specify the list of [fingers] allowed to be scanned (defaults to [Finger.all]),
  /// and custom [scanner] instance to mock or override method channel interactions.
  ScannerController({List<Finger> fingers = Finger.all, FlutterBiometricFinger scanner = const FlutterBiometricFinger()})
    : allowedFingers = List.unmodifiable(fingers),
      _scanner = scanner;

  /// The list of fingers that are configured/allowed to be scanned.
  final List<Finger> allowedFingers;
  final FlutterBiometricFinger _scanner;

  bool _isBusy = false;
  bool _isInitialized = false;
  String _status = 'Connect the scanner, then tap Initialize.';
  int? _scanningFingerId;
  ScannerDevice? _device;
  final Map<int, FingerScanResult> _results = {};

  /// Returns true if the controller is currently executing a native operation (init, scan, dispose).
  bool get isBusy => _isBusy;

  /// Returns true if a live connection session has been successfully opened with a scanner.
  bool get isInitialized => _isInitialized;

  /// The current state message or prompt description.
  String get status => _status;

  /// The ID of the [Finger] currently being scanned, if any.
  int? get scanningFingerId => _scanningFingerId;

  /// The initialized scanner device metadata.
  ScannerDevice? get device => _device;

  /// A read-only map of captured [FingerScanResult] indexed by finger ID.
  Map<int, FingerScanResult> get results => Map.unmodifiable(_results);

  /// The total number of fingers that have been successfully scanned.
  int get scrolledCount => _results.length; // Keeping backwards compatibility if needed, but let's expose proper name

  /// The total number of fingers that have been successfully scanned.
  int get scannedCount => _results.length;

  /// The total number of allowed fingers.
  int get totalCount => allowedFingers.length;

  /// Returns true if all allowed fingers have been successfully scanned.
  bool get allScanned => scannedCount == totalCount;

  /// Returns true if the specified [finger] has a captured scan result.
  bool isScanned(Finger finger) => _results.containsKey(finger.id);

  /// Returns true if the specified [finger] is currently being scanned.
  bool isScanning(Finger finger) => _scanningFingerId == finger.id;

  /// Retrieves the captured [FingerScanResult] for the specified [finger].
  FingerScanResult? resultFor(Finger finger) => _results[finger.id];

  /// Initializes the fingerprint scanner hardware.
  ///
  /// Clears any cached scan results and opens a live connection session.
  /// Returns the detected [ScannerDevice] or null if the session could not be established.
  Future<ScannerDevice?> initialize() async {
    if (_isBusy) return _device;
    _setBusy(true, 'Initializing scanner...');
    _results.clear();

    try {
      final scannerDevice = await _scanner.initialize();
      _device = scannerDevice;
      _isInitialized = scannerDevice.found;
      _status = scannerDevice.message;
      dev.log('[ScannerController] Initialized: ${scannerDevice.raw}');
      return scannerDevice;
    } catch (error, stackTrace) {
      _isInitialized = false;
      dev.log('[ScannerController] Init error', error: error, stackTrace: stackTrace);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  /// Closes the scanner communication session and clears all captured results.
  Future<void> disposeScanner() async {
    if (_isBusy) return;
    _setBusy(true, 'Disposing session...');

    try {
      await _scanner.dispose();
      _device = null;
      _isInitialized = false;
      _results.clear();
      dev.log('[ScannerController] Disposed.');
    } catch (error, stackTrace) {
      dev.log('[ScannerController] Dispose error', error: error, stackTrace: stackTrace);
      rethrow;
    } finally {
      _setBusy(false);
    }
  }

  /// Clears all captured scan results from memory.
  void clearResults() {
    _results.clear();
    _status = 'Results cleared.';
    notifyListeners();
  }

  /// Initiates the scanning flow for a specific [finger].
  ///
  /// Prompts the user, executes native scan extraction, caches the [FingerScanResult],
  /// and triggers listeners.
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
      dev.log('[ScannerController] Scan error (${finger.label})', error: error, stackTrace: stackTrace);
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
      '[ScannerController] ${result.finger.label}\n'
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
