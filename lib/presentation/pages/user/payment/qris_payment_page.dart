import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/blocs/payment/payment_cubit.dart';
import 'package:parqr/presentation/blocs/payment/payment_state.dart';
import 'package:parqr/presentation/widgets/qr_display_card.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class QrisPaymentPage extends StatelessWidget {
  const QrisPaymentPage({
    super.key,
    required this.sessionId,
    required this.totalTariff,
    required this.totalDuration,
  });

  final String sessionId;
  final double totalTariff;
  final int totalDuration;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit()..processQrisPayment(),
      child: QrisPaymentView(
        sessionId: sessionId,
        totalTariff: totalTariff,
        totalDuration: totalDuration,
      ),
    );
  }
}

class QrisPaymentView extends StatefulWidget {
  const QrisPaymentView({
    super.key,
    required this.sessionId,
    required this.totalTariff,
    required this.totalDuration,
  });

  final String sessionId;
  final double totalTariff;
  final int totalDuration;

  @override
  State<QrisPaymentView> createState() => _QrisPaymentViewState();
}

class _QrisPaymentViewState extends State<QrisPaymentView> {
  int _secondsRemaining = 600; // 10 minutes
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        _countdownTimer?.cancel();
        if (mounted) {
          context.read<PaymentCubit>().cancelPayment();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran QRIS kedaluwarsa.')),
          );
          context.pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatCountdown(int totalSeconds) {
    final minutes = (totalSeconds / 60).floor();
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final formattedTariff = widget.totalTariff.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    return BlocListener<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          context.go(
            RouteNames.exitQr,
            extra: {
              'exitQrPayload': state.exitQrPayload,
              'tariff': widget.totalTariff,
              'durationInSeconds': widget.totalDuration,
              'method': 'QRIS',
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran QRIS'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              context.read<PaymentCubit>().cancelPayment();
              context.pop();
            },
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // Countdown header
              Center(
                child: Column(
                  children: [
                    const StatusBadge(
                      label: 'MENUNGGU PEMBAYARAN',
                      type: StatusBadgeType.pending,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selesaikan pembayaran dalam waktu',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCountdown(_secondsRemaining),
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.warning,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Qr Code Display Card
              QrDisplayCard(
                data: 'https://qris.id/pay?session=${widget.sessionId}&amount=${widget.totalTariff}',
                title: 'ParQr Sudirman Hub',
                subtitle: 'Total Tagihan: Rp$formattedTariff',
                size: 200,
              ),
              const SizedBox(height: 24),

              // Information card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.accentBlue, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cara Membayar:',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _StepRow(step: '1', text: 'Screenshot QR code di atas.'),
                    const _StepRow(step: '2', text: 'Buka aplikasi e-wallet (Gopay, OVO, Dana, LinkAja) atau m-banking Anda.'),
                    const _StepRow(step: '3', text: 'Pilih opsi Scan / Bayar, lalu unggah gambar QR dari galeri Anda.'),
                    const _StepRow(step: '4', text: 'Selesaikan transaksi. Halaman ini akan otomatis diperbarui.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Polling Status Loader
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.accentBlue),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Mendeteksi pembayaran...',
                    style: TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.text,
  });

  final String step;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.bgElevated,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
