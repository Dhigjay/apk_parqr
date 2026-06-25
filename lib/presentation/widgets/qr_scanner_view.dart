import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerView extends StatefulWidget {
  final void Function(String rawValue) onDetect;
  final String hint;

  const QrScannerView({
    super.key,
    required this.onDetect,
    this.hint = 'Arahkan kamera ke QR Code',
  });

  @override
  State<QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<QrScannerView> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final barcode = capture.barcodes.firstOrNull;
            if (barcode?.rawValue != null && !_hasScanned) {
              _hasScanned = true;
              widget.onDetect(barcode!.rawValue!);
            }
          },
        ),
        // Dark overlay with transparent scan area
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.55),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Corner border decorations
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00C2FF), width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        // Hint text
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Text(
            widget.hint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Reset button if needed
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                setState(() => _hasScanned = false);
              },
              icon: const Icon(Icons.refresh, color: Color(0xFF00C2FF)),
              label: const Text(
                'Scan Ulang',
                style: TextStyle(color: Color(0xFF00C2FF)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
