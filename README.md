# Flutter Biometric Finger

A powerful Flutter plugin for integrating **NEXT Biometrics** USB fingerprint scanners on Android.

This package provides a clean Flutter API for:

* Fingerprint image capture
* ISO template extraction
* Multi finger enrollment
* 1:1 verification flows
* Scanner lifecycle management
* PNG fingerprint preview rendering

Built for production grade biometric enrollment and verification workflows.

---

## Features

* USB fingerprint scanner initialization
* ISO compliant fingerprint template extraction
* PNG fingerprint image generation
* Single finger verification
* Multi finger enrollment
* Real time quality metrics
* Finger spoof detection support
* Clean Flutter widget API
* Android native SDK integration using Kotlin
* Automatic SDK binary download during build

---

## Supported Hardware

Tested Devices:

| Type     | Model          |
| -------- | -------------- |
| NB65200U | AbeTree-ATS-24 |

---

## Platform Support

| Platform | Support |
| -------- | ------- |
| Android  | ✅       |
| iOS      | ❌       |
| Web      | ❌       |
| Windows  | ❌       |
| macOS    | ❌       |
| Linux    | ❌       |

Minimum Android SDK: `24`

---

## Installation

Add dependency:

```yaml
dependencies:
  flutter_biometric_finger: ^0.0.1
```

Run:

```bash
flutter pub get
```

---

## Android Configuration

### Android 11+ Requirement

Add this attribute inside your `AndroidManifest.xml` application tag:

```xml
<application
    android:name="${applicationName}"
    android:label="your_app_name"
    android:icon="@mipmap/ic_launcher"
    android:allowNativeHeapPointerTagging="false">
```

This prevents crashes caused by legacy native biometric SDKs on Android 11+ devices.

---

## 💻 Usage

### 1. Initialize the Scanner

Before scanning, you must initialize the device.

```dart
import 'package:flutter_biomatric_finger/flutter_biomatric_finger.dart';

final scanner = FlutterBiomatricFinger();

final device = await scanner.initialize();

if (!device.found) {
  print("Scanner not found: ${device.message}");
  return;
}

print("Scanner initialized successfully!");
```

---

### 2. Scan and Extract Data

Once initialized, prompt the user to place their finger on the scanner and call `scanAndExtract()`.

```dart
final scan = await scanner.scanAndExtract();

if (scan.status == 'success') {
  print("Scan Quality: ${scan.quality}");
  print("ISO Template (Base64): ${scan.templateBase64}");
} else {
  print("Scan failed: ${scan.status}");
}
```

---

### 3. Display the Fingerprint Image

The plugin automatically converts the raw scanner data into a standard PNG format. You can easily display it using Flutter's `Image.memory` widget.

```dart
if (scan.imagePngBytes != null) {
  Image.memory(scan.imagePngBytes!);
}
```

---

### 4. Dispose

Always dispose of the scanner when you are done to release the USB interface and free up memory.

```dart
await scanner.dispose();
```

---

## Quick Start

Import package:

```dart
import 'package:flutter_biometric_finger/flutter_biometric_finger.dart';
```

---

# Initialize Scanner

```dart
final controller = ScannerController();

await controller.initialize();
```

---

# Single Finger Verification

```dart
final controller = ScannerController(
  fingers: [Finger.rightThumb],
);
```

---

# Right Hand Enrollment

```dart
final controller = ScannerController(
  fingers: Finger.rightHand,
);
```

---

# Custom Finger Selection

```dart
final controller = ScannerController(
  fingers: const [
    Finger.rightIndex,
    Finger.leftIndex,
  ],
);
```

---

# Scanner Widget

```dart
ScannerWidget(
  controller: controller,
)
```

---

# Scan Callback

```dart
ScannerWidget(
  controller: controller,
  onScanComplete: (result) {
    debugPrint(result.templateBase64);
  },
)
```

---

## Full Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_biometric_finger/flutter_biometric_finger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ScannerPage(),
    );
  }
}

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late final ScannerController controller;

  @override
  void initState() {
    super.initState();

    controller = ScannerController(
      fingers: [Finger.rightThumb],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fingerprint Scanner')),
      body: ScannerWidget(
        controller: controller,
        onScanComplete: (result) {
          debugPrint(
            'Template length: ${result.templateBase64.length}',
          );
        },
      ),
    );
  }
}
```

---

## Scan Result

Each completed scan returns:

```dart
result.templateBase64
result.imagePngBytes
result.quality
result.finger
result.spoofScore
result.scanMillis
```

---

## Finger Presets

Available presets:

```dart
Finger.rightThumb
Finger.leftThumb
Finger.rightHand
Finger.leftHand
Finger.all
```

Or custom selection:

```dart
[
  Finger.rightIndex,
  Finger.leftIndex,
]
```

---

## Example App

The package includes a fully functional example application demonstrating:

* All 10 finger capture
* Single finger verification
* Right hand enrollment
* Custom subset scanning
* Fingerprint preview rendering
* ISO template extraction

Run example:

```bash
cd example
flutter run
```

---

## Troubleshooting

### Scanner Not Found

Check:

* USB OTG is enabled
* Scanner is connected properly
* USB permission was granted

---

### App Crashes During Scan

Verify:

```xml
android:allowNativeHeapPointerTagging="false"
```

is added inside the application tag.

---

### Unsupported Device

Currently tested only with:

* NB65200U
* AbeTree-ATS-24

Other NEXT Biometrics devices may work but are not officially verified.

---

## Architecture

This plugin uses:

* Flutter MethodChannel
* Native Android Kotlin integration
* AbeTree / NEXT Biometrics Android SDK
* USB host communication
* ISO fingerprint template extraction

---

## License

BSD 3-Clause License
