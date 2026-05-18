import 'package:flutter/material.dart';
import 'package:flutter_biometric_finger/flutter_biometric_finger.dart';

void main() {
  runApp(const ScannerExampleApp());
}

class ScannerExampleApp extends StatelessWidget {
  const ScannerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF067BB1)),
        useMaterial3: true,
      ),
      home: const ExamplesMenu(),
    );
  }
}

class ExamplesMenu extends StatelessWidget {
  const ExamplesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('All 10 fingers — full test'),
            leading: const Icon(Icons.fingerprint),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AllFingersPage())),
          ),
          ListTile(
            title: const Text('Right thumb only — 1:1 verification'),
            leading: const Icon(Icons.thumb_up_outlined),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SingleFingerPage())),
          ),
          ListTile(
            title: const Text('Right hand only — enrollment'),
            leading: const Icon(Icons.front_hand_outlined),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RightHandPage())),
          ),
          ListTile(
            title: const Text('Custom subset — 2 fingers'),
            leading: const Icon(Icons.tune),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CustomSubsetPage())),
          ),
        ],
      ),
    );
  }
}

class AllFingersPage extends StatefulWidget {
  const AllFingersPage({super.key});

  @override
  State<AllFingersPage> createState() => _AllFingersPageState();
}

class _AllFingersPageState extends State<AllFingersPage> {
  late final ScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = ScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Fingers')),
      body: SingleChildScrollView(child: ScannerWidget(controller: controller)),
    );
  }
}

class SingleFingerPage extends StatefulWidget {
  const SingleFingerPage({super.key});

  @override
  State<SingleFingerPage> createState() => _SingleFingerPageState();
}

class _SingleFingerPageState extends State<SingleFingerPage> {
  late final ScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = ScannerController(fingers: [Finger.rightThumb]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Right Thumb Only')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return FilledButton.icon(
                  onPressed: controller.isBusy ? null : controller.initialize,
                  icon: const Icon(Icons.usb),
                  label: const Text('Connect Scanner'),
                );
              },
            ),
          ),
          ScannerWidget(
            controller: controller,
            showLifecycleBar: false,
            showClearButton: false,
            expandedByDefault: true,
            onScanComplete: (result) {
              debugPrint(
                'Template ready: ${result.templateBase64.length} chars',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${result.finger.label} captured.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RightHandPage extends StatefulWidget {
  const RightHandPage({super.key});

  @override
  State<RightHandPage> createState() => _RightHandPageState();
}

class _RightHandPageState extends State<RightHandPage> {
  late final ScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = ScannerController(fingers: Finger.rightHand);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Right Hand Enrollment')),
      body: SingleChildScrollView(child: ScannerWidget(controller: controller)),
    );
  }
}

class CustomSubsetPage extends StatefulWidget {
  const CustomSubsetPage({super.key});

  @override
  State<CustomSubsetPage> createState() => _CustomSubsetPageState();
}

class _CustomSubsetPageState extends State<CustomSubsetPage> {
  late final ScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = ScannerController(
      fingers: const [Finger.rightIndex, Finger.leftIndex],
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
      appBar: AppBar(title: const Text('Index Fingers Only')),
      body: SingleChildScrollView(
        child: ScannerWidget(
          controller: controller,
          onScanComplete: (result) {
            debugPrint('Scanned: $result');
          },
        ),
      ),
    );
  }
}
