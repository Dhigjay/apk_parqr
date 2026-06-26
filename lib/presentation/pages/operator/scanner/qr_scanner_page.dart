import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String rawValue = barcodes.first.rawValue!;
      setState(() {
        _hasScanned = true;
      });

      // Stop camera scanning
      _scannerController.stop();

      // Navigate to scanned vehicle details with raw QR value
      context.pushReplacement(
        '/scanned-vehicle',
        extra: {
          'qrPayload': rawValue,
          'licensePlate': 'B ${1000 + (rawValue.hashCode % 8999)} AB',
          'vehicleName': 'Toyota Avanza (Mock)',
          'checkInTime': DateTime.now().toIso8601String(),
          'floor': 'Lantai 1',
          'currentTariff': 5000.0,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Parkir'),
        actions: [
          IconButton(
            onPressed: () => _scannerController.toggleTorch(),
            icon: ValueListenableBuilder<TorchState>(
              valueListenable: _scannerController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off_rounded);
                  case TorchState.on:
                    return const Icon(Icons.flash_on_rounded, color: AppColors.warning);
                }
              },
            ),
          ),
          IconButton(
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(Icons.flip_camera_ios_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Dark overlay with cut-out viewfinder
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.65),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black, // Color used for cutout shape
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Viewfinder glowing borders
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.accentBlue, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.22),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Instructions Overlay
          Positioned(
            bottom: 60,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Text(
                  'Arahkan kamera ke QR Code',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scan QR Code masuk atau keluar milik pengunjung untuk melakukan pencatatan parkir.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
