import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      create: (context) => PaymentCubit()..processQrisPayment(sessionId, totalTariff),
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

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label disalin!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
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

              // QR Code + Link Section
              BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentProcessing) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Membuat QRIS dari Midtrans...'),
                          ],
                        ),
                      ),
                    );
                  } else if (state is PaymentQrisGenerated) {
                    final hasQrisUrl = state.qrisUrl.isNotEmpty;

                    return Column(
                      children: [
                        // QR Code card
                        QrDisplayCard(
                          data: hasQrisUrl
                              ? state.qrisUrl
                              : 'https://qris.placeholder/${widget.sessionId}',
                          title: 'ParQr',
                          subtitle: 'Total Tagihan: Rp$formattedTariff',
                          size: 200,
                        ),

                        // QRIS URL section (for sandbox simulation)
                        if (hasQrisUrl) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.link_rounded,
                                      color: AppColors.accentBlue,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Link QRIS (untuk simulasi sandbox)',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.accentBlue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgElevated,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          state.qrisUrl,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textSecondary,
                                            fontFamily: 'monospace',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.copy_rounded,
                                          color: AppColors.accentBlue,
                                          size: 18,
                                        ),
                                        onPressed: () => _copyToClipboard(
                                          context,
                                          state.qrisUrl,
                                          'Link QRIS',
                                        ),
                                        tooltip: 'Salin link',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Sandbox simulation hint
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.warning.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.science_rounded,
                                        color: AppColors.warning,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Mode Sandbox: Salin link di atas → buka di browser untuk melihat QR → lalu simulasikan pembayaran di Midtrans Dashboard.',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.warning,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  } else if (state is PaymentFailed) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox(height: 200);
                },
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
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.accentBlue, size: 20),
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
                    const _StepRow(
                        step: '2',
                        text: 'Buka aplikasi e-wallet (Gopay, OVO, Dana, LinkAja) atau m-banking.'),
                    const _StepRow(
                        step: '3',
                        text: 'Pilih Scan / Bayar, lalu unggah gambar QR dari galeri.'),
                    const _StepRow(
                        step: '4',
                        text: 'Selesaikan transaksi. Halaman ini akan otomatis diperbarui.'),
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
                  ),
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
  const _StepRow({required this.step, required this.text});
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
