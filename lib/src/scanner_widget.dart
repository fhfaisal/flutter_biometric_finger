import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard

import 'finger.dart';
import 'finger_scan_result.dart';
import 'scanner_controller.dart';

// ════════════════════════════════════════════════════════════════════════════
// ScannerWidget
// ════════════════════════════════════════════════════════════════════════════

class ScannerWidget extends StatelessWidget {
  const ScannerWidget({
    super.key,
    required this.controller,
    this.onScanComplete,
    this.onError,
    this.showStatusBar = true,
    this.showLifecycleBar = true,
    this.showClearButton = true,
    this.expandedByDefault = false,
  });

  final ScannerController controller;

  /// Called after every successful scan or rescan.
  final void Function(FingerScanResult result)? onScanComplete;

  /// Called whenever initialize, dispose, or scanFinger throws.
  ///
  /// [finger] is non-null only for scan errors; null for lifecycle errors
  /// (initialize / dispose). Use it to know which finger failed.
  final void Function(Object error, {Finger? finger})? onError;

  final bool showStatusBar;
  final bool showLifecycleBar;
  final bool showClearButton;
  final bool expandedByDefault;

  void _handleError(Object error, {Finger? finger}) => onError?.call(error, finger: finger);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showStatusBar) _StatusBar(controller: controller),
            if (showLifecycleBar)
              _LifecycleBar(controller: controller, showClear: showClearButton, onError: (e) => _handleError(e)),
            if (showLifecycleBar || showStatusBar) const Divider(height: 1),
            _FingerListSection(
              controller: controller,
              onScanComplete: onScanComplete,
              expandedByDefault: expandedByDefault,
              onError: (e, {finger}) => _handleError(e, finger: finger),
            ),
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Status bar  (unchanged internally)
// ════════════════════════════════════════════════════════════════════════════

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.controller});

  final ScannerController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          color: theme.colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                controller.isInitialized ? Icons.circle : Icons.circle_outlined,
                size: 9,
                color: controller.isInitialized ? Colors.green.shade600 : theme.colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.status,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              if (controller.totalCount > 1)
                Text(
                  '${controller.scannedCount}/${controller.totalCount}',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ),
        if (controller.isBusy)
          LinearProgressIndicator(
            minHeight: 2,
            color: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.primaryContainer,
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Lifecycle bar — Initialize / Dispose / Clear
// ════════════════════════════════════════════════════════════════════════════

class _LifecycleBar extends StatelessWidget {
  const _LifecycleBar({required this.controller, required this.showClear, required this.onError});

  final ScannerController controller;
  final bool showClear;
  final void Function(Object error) onError;

  @override
  Widget build(BuildContext context) {
    final busy = controller.isBusy;
    final initialized = controller.isInitialized;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: busy
                  ? null
                  : () async {
                      try {
                        await controller.initialize();
                      } catch (e) {
                        onError(e);
                      }
                    },
              icon: const Icon(Icons.usb, size: 17),
              label: const Text('Initialize'),
              style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: (busy || !initialized)
                  ? null
                  : () async {
                      try {
                        await controller.disposeScanner();
                      } catch (e) {
                        onError(e);
                      }
                    },
              icon: const Icon(Icons.power_settings_new, size: 17),
              label: const Text('Dispose'),
              style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ),
          if (showClear) ...[
            const SizedBox(width: 8),
            IconButton.outlined(
              tooltip: 'Clear results',
              onPressed: busy ? null : controller.clearResults,
              icon: const Icon(Icons.refresh, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Finger list
// ════════════════════════════════════════════════════════════════════════════

class _FingerListSection extends StatelessWidget {
  const _FingerListSection({
    required this.controller,
    required this.onScanComplete,
    required this.expandedByDefault,
    required this.onError,
  });

  final ScannerController controller;
  final void Function(FingerScanResult)? onScanComplete;
  final bool expandedByDefault;
  final void Function(Object error, {Finger? finger}) onError;

  @override
  Widget build(BuildContext context) {
    final fingers = controller.allowedFingers;
    final hasRight = fingers.any((f) => f.isRight);
    final hasLeft = fingers.any((f) => f.isLeft);
    final bothHands = hasRight && hasLeft;
    final rightFingers = fingers.where((f) => f.isRight).toList();
    final leftFingers = fingers.where((f) => f.isLeft).toList();

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (hasRight) ...[
          if (bothHands) _HandHeader(label: 'Right Hand', icon: Icons.front_hand_outlined),
          ...rightFingers.map(
            (f) => _FingerTile(
              key: ValueKey(f.id),
              finger: f,
              controller: controller,
              onScanComplete: onScanComplete,
              initiallyExpanded: expandedByDefault,
              onError: onError,
            ),
          ),
        ],
        if (hasLeft) ...[
          if (bothHands) ...[const SizedBox(height: 4), _HandHeader(label: 'Left Hand', icon: Icons.back_hand_outlined)],
          ...leftFingers.map(
            (f) => _FingerTile(
              key: ValueKey(f.id),
              finger: f,
              controller: controller,
              onScanComplete: onScanComplete,
              initiallyExpanded: expandedByDefault,
              onError: onError,
            ),
          ),
        ],
      ],
    );
  }
}

class _HandHeader extends StatelessWidget {
  const _HandHeader({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Individual finger tile
// ════════════════════════════════════════════════════════════════════════════

class _FingerTile extends StatelessWidget {
  const _FingerTile({
    super.key,
    required this.finger,
    required this.controller,
    required this.onScanComplete,
    required this.initiallyExpanded,
    required this.onError,
  });

  final Finger finger;
  final ScannerController controller;
  final void Function(FingerScanResult)? onScanComplete;
  final bool initiallyExpanded;
  final void Function(Object error, {Finger? finger}) onError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scanned = controller.isScanned(finger);
    final scanning = controller.isScanning(finger);
    final busy = controller.isBusy;
    final initialized = controller.isInitialized;
    final data = controller.resultFor(finger);

    final trailing = scanning
        ? Padding(
            padding: const EdgeInsets.only(right: 4),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.primary),
            ),
          )
        : IconButton(
            tooltip: scanned ? 'Rescan ${finger.label}' : 'Scan ${finger.label}',
            onPressed: (busy || !initialized)
                ? null
                : () async {
                    try {
                      final result = await controller.scanFinger(finger);
                      if (result != null) onScanComplete?.call(result);
                    } catch (e) {
                      onError(e, finger: finger);
                    }
                  },
            icon: Icon(scanned ? Icons.refresh_rounded : Icons.fingerprint),
            color: (busy || !initialized)
                ? theme.colorScheme.outline.withValues(alpha: 0.35)
                : scanned
                ? theme.colorScheme.secondary
                : theme.colorScheme.primary,
          );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: scanned
              ? theme.colorScheme.secondary.withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      color: scanned ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.25) : theme.colorScheme.surfaceContainerLow,
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: _Badge(label: '${finger.id}', scanned: scanned),
          title: Text(finger.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: scanned
              ? Text(
                  'Q: ${data!.quality}  ·  ${data.scanMillis} ms  ·  ${data.templateLength} B',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                )
              : Text(
                  initialized ? 'Tap to scan' : 'Initialize first',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
          trailing: trailing,
          children: [_ExpandedBody(data: data, initialized: initialized)],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Expanded body — fingerprint image
// ════════════════════════════════════════════════════════════════════════════

class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({required this.data, required this.initialized});

  final FingerScanResult? data;
  final bool initialized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          children: [
            const Divider(),
            const SizedBox(height: 16),
            Icon(Icons.fingerprint, size: 52, color: theme.colorScheme.outline.withValues(alpha: 0.35)),
            const SizedBox(height: 8),
            Text(
              initialized ? 'Tap the scan icon to capture this finger' : 'Initialize the scanner first',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    final result = data!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 12),
          if (result.scan.imagePngBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(result.scan.imagePngBytes!, width: 200, fit: BoxFit.contain, gaplessPlayback: true),
            )
          else
            Column(
              children: [
                Icon(Icons.image_not_supported_outlined, size: 48, color: theme.colorScheme.outline),
                const SizedBox(height: 4),
                Text('No image returned', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Chip(label: result.status, ok: result.isSuccess),
              const SizedBox(width: 8),
              _Chip(label: 'Q: ${result.quality}', ok: true),
            ],
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: result.templateBase64.isEmpty ? null : () => Clipboard.setData(ClipboardData(text: result.templateBase64)),
            icon: const Icon(Icons.copy, size: 15),
            label: const Text('Copy ISO Template'),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Small shared widgets
// ═══════════════════════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.scanned});

  final String label;
  final bool scanned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scanned ? theme.colorScheme.secondary : theme.colorScheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: scanned ? theme.colorScheme.onSecondary : theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ok ? Colors.green.withValues(alpha: 0.12) : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: ok ? Colors.green.shade800 : theme.colorScheme.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
