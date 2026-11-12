import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../state/app_controller.dart';
import '../theme/cwear_theme.dart';
import '../widgets/common.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key, required this.state, required this.onConnected});
  final AppController state;
  final VoidCallback onConnected;
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  late final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
    autoStart: false,
  );
  bool _showCamera = false;
  bool _handlingCode = false;

  @override
  void initState() {
    super.initState();
    _showCamera = !widget.state.connected;
    if (_showCamera) _startCamera();
  }

  Future<void> _startCamera() async {
    // Give the route time to mount before CameraX/AVFoundation starts.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || !_showCamera) return;
      try {
        await _scanner.start();
      } catch (_) {
        // MobileScanner's errorBuilder will display a permission/camera error.
      }
    });
  }

  Future<void> _onDetected(BarcodeCapture capture) async {
    if (_handlingCode || !_showCamera) return;
    for (final code in capture.barcodes) {
      final payload = code.rawValue?.trim();
      if (payload != null && payload.isNotEmpty) {
        await _connect(payload);
        return;
      }
    }
  }

  Future<void> _connect(String code) async {
    if (_handlingCode || code.trim().isEmpty) return;
    setState(() => _handlingCode = true);
    // Intentional demo: QR payload is used as a trigger, never for real pairing.
    await widget.state.connectDemo(code);
    if (!mounted) return;
    widget.onConnected();
  }

  Future<void> _manualCode() async {
    final input = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter sensor code'),
        content: TextField(
          controller: input,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
              hintText: 'C-WEAR-001', labelText: 'QR / sensor code'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, input.text),
              child: const Text('Start demo')),
        ],
      ),
    );
    input.dispose();
    if (!mounted || result == null) return;
    if (result.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a sensor code.')));
      return;
    }
    await _connect(result);
  }

  Future<void> _toggleCamera() async {
    if (_showCamera) {
      await _scanner.stop();
      if (!mounted) return;
      setState(() => _showCamera = false);
    } else {
      setState(() => _showCamera = true);
      await _startCamera();
    }
  }

  Future<void> _disconnect() async {
    await widget.state.disconnectDemo();
    if (!mounted) return;
    setState(() => _showCamera = true);
    await _startCamera();
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.state.connected;
    return ScreenBody(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CWHeader(),
        const SizedBox(height: 16),
        const Text('L E T ’ S   G E T   C O N N E C T E D',
            style: TextStyle(fontSize: 10, color: CW.teal,
                fontWeight: FontWeight.w800, letterSpacing: .2)),
        const SizedBox(height: 9),
        Text('Connect your sensor',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        const Text('Scan the QR code on your C-Wear to start monitoring your breathing.',
            style: TextStyle(color: CW.muted, fontSize: 14, height: 1.48)),
        const SizedBox(height: 25),
        _StepProgress(isConnected: isConnected),
        const SizedBox(height: 23),
        AspectRatio(
          aspectRatio: 1.24,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(fit: StackFit.expand, children: [
              if (_showCamera)
                MobileScanner(
                  controller: _scanner,
                  onDetect: _onDetected,
                  errorBuilder: (context, error) => Container(
                    color: const Color(0xFFB4C5BE),
                    padding: const EdgeInsets.all(22),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.no_photography_outlined,
                            color: CW.ink, size: 34),
                        const SizedBox(height: 12),
                        const Text('Camera unavailable',
                            style: TextStyle(color: CW.ink,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Allow camera access in Settings, or enter the code manually.\n${error.errorCode}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: CW.ink)),
                      ],
                    ),
                  ),
                )
              else
                const ColoredBox(
                  color: Color(0xFF17494A),
                  child: Center(
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 72,
                      color: Color(0xFFB9E9D9),
                    ),
                  ),
                ),
              Container(color: Colors.black.withValues(alpha: .13)),
              if (_showCamera)
                const Positioned.fill(child: IgnorePointer(
                    child: CustomPaint(painter: _ScanCorners()))),
              Positioned(top: 17, left: 17,
                child: _CameraTag(text: _showCamera
                    ? 'Camera ready' : 'Demo sensor connected')),
              Positioned(top: 15, right: 15,
                child: Material(color: const Color(0xB9003E43),
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: _showCamera ? 'Toggle flashlight' : 'Scan another QR',
                    color: Colors.white,
                    icon: Icon(_showCamera ? Icons.flashlight_on_outlined
                        : Icons.qr_code_scanner),
                    onPressed: () async {
                      if (!_showCamera) {
                        await _toggleCamera();
                      } else {
                        try { await _scanner.toggleTorch(); } catch (_) { /* unsupported torch */ }
                      }
                    },
                  ),
                ),
              ),
              Positioned(bottom: 22, left: 10, right: 10,
                child: Text(_showCamera ? 'Place the QR code inside the frame'
                    : 'QR detected · simulation is active',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white,
                        shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                        fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          ),
        ),
        const SizedBox(height: 23),
        Row(children: [
          Container(width: 42, height: 42,
              decoration: BoxDecoration(color: CW.tealPale,
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(isConnected ? Icons.check_circle_outline
                  : Icons.bluetooth_outlined, color: CW.teal)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isConnected ? 'C-Wear · Connected (demo)' : 'Ready to scan',
                  style: const TextStyle(color: CW.ink,
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(isConnected ? 'Simulated readings are available on Live and History.'
                  : 'No Bluetooth pairing is required for this demo.',
                  style: const TextStyle(color: CW.muted, fontSize: 12)),
            ],
          )),
        ]),
        const SizedBox(height: 15),
        Text(isConnected
            ? 'You can revisit Live at any time, or disconnect to see the empty monitoring state.'
            : 'After scanning, the demo will automatically open your live respiration view.',
            style: const TextStyle(color: CW.muted, fontSize: 12, height: 1.4)),
        const SizedBox(height: 25),
        SizedBox(width: double.infinity, height: 50,
          child: OutlinedButton.icon(onPressed: _manualCode,
            icon: const Icon(Icons.keyboard_outlined),
            label: const Text('Enter sensor code manually'),
            style: OutlinedButton.styleFrom(foregroundColor: CW.ink,
              side: const BorderSide(color: CW.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ),
        const SizedBox(height: 6),
        Center(child: TextButton(
          onPressed: () => showDialog<void>(context: context,
              builder: (context) => AlertDialog(
                title: const Text('Where is my QR code?'),
                content: const Text('Look on the sensor housing, its packaging, or its label. For this demo, any QR code can activate the simulated monitor.'),
                actions: [TextButton(onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'))],
              )),
          child: const Text('Where can I find my QR code?',
              style: TextStyle(color: CW.teal, fontWeight: FontWeight.w700)),
        )),
        if (isConnected) ...[
          Center(child: TextButton.icon(
              onPressed: _disconnect,
              icon: const Icon(Icons.link_off),
              label: const Text('Disconnect demo sensor'))),
        ],
      ],
    ));
  }
}

class _CameraTag extends StatelessWidget {
  const _CameraTag({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: const Color(0xD900474B),
        borderRadius: BorderRadius.circular(18)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.circle, size: 7, color: Color(0xFFAEF1DD)),
      const SizedBox(width: 5),
      Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    ]),
  );
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.isConnected});
  final bool isConnected;
  @override
  Widget build(BuildContext context) => Row(children: [
    _step('1', 'Scan', isConnected ? false : true),
    const Expanded(child: Divider(indent: 8, endIndent: 8, color: CW.line)),
    _step('2', 'Connect', isConnected),
    const Expanded(child: Divider(indent: 8, endIndent: 8, color: CW.line)),
    _step('3', 'Monitor', isConnected),
  ]);
  Widget _step(String number, String label, bool active) => Row(children: [
    CircleAvatar(radius: 13, backgroundColor: active ? CW.teal : CW.soft,
      child: Text(number, style: TextStyle(fontSize: 11,
          color: active ? Colors.white : CW.muted,
          fontWeight: FontWeight.bold))),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(fontSize: 12,
        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
        color: active ? CW.ink : CW.muted)),
  ]);
}

class _ScanCorners extends CustomPainter {
  const _ScanCorners();
  @override
  void paint(Canvas canvas, Size size) {
    final x0 = size.width * .22;
    final x1 = size.width * .78;
    final y0 = size.height * .22;
    final y1 = size.height * .78;
    const cornerLength = 23.0;
    final paint = Paint()..color = const Color(0xFFC4FFE7)
      ..strokeWidth = 3.5..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final lines = Path()
      ..moveTo(x0, y0 + cornerLength)..lineTo(x0, y0)..lineTo(x0 + cornerLength, y0)
      ..moveTo(x1 - cornerLength, y0)..lineTo(x1, y0)..lineTo(x1, y0 + cornerLength)
      ..moveTo(x0, y1 - cornerLength)..lineTo(x0, y1)..lineTo(x0 + cornerLength, y1)
      ..moveTo(x1 - cornerLength, y1)..lineTo(x1, y1)..lineTo(x1, y1 - cornerLength);
    canvas.drawPath(lines, paint);
    canvas.drawLine(Offset(x0 + 12, size.height / 2),
        Offset(x1 - 12, size.height / 2),
        Paint()..color = const Color(0x99CBFFED)..strokeWidth = 1);
  }
  @override
  bool shouldRepaint(covariant _ScanCorners oldDelegate) => false;
}
