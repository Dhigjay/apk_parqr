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
import 'package:parqr/presentation/widgets/status_badge.dart';

class VaPaymentPage extends StatelessWidget {
  const VaPaymentPage({
    super.key,
    required this.sessionId,
    required this.totalTariff,
    required this.totalDuration,
    required this.bank,
  });

  final String sessionId;
  final double totalTariff;
  final int totalDuration;
  final String bank;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit()..processVaPayment(sessionId, totalTariff, bank),
      child: VaPaymentView(
        sessionId: sessionId,
        totalTariff: totalTariff,
        totalDuration: totalDuration,
        bank: bank,
      ),
    );
  }
}

class VaPaymentView extends StatefulWidget {
  const VaPaymentView({
    super.key,
    required this.sessionId,
    required this.totalTariff,
    required this.totalDuration,
    required this.bank,
  });

  final String sessionId;
  final double totalTariff;
  final int totalDuration;
  final String bank;

  @override
  State<VaPaymentView> createState() => _VaPaymentViewState();
}

class _VaPaymentViewState extends State<VaPaymentView> {
  int _secondsRemaining = 86400; // 24 hours typical for VA, but for demo let's use 600 or 86400
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
            const SnackBar(content: Text('Pembayaran Virtual Account kedaluwarsa.')),
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
    final hours = (totalSeconds / 3600).floor();
    final minutes = ((totalSeconds % 3600) / 60).floor();
    final seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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
              'method': 'VA ${widget.bank.toUpperCase()}',
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Virtual Account ${widget.bank.toUpperCase()}'),
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

              // VA Display Card
              BlocBuilder<PaymentCubit, PaymentState>(
                builder: (context, state) {
                  if (state is PaymentProcessing) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is PaymentVaGenerated) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text('Nomor Virtual Account', style: AppTextStyles.bodySecondary),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.vaNumber,
                                style: AppTextStyles.h2.copyWith(color: AppColors.accentBlue, letterSpacing: 1.5),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, color: AppColors.accentBlue, size: 20),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: state.vaNumber));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Nomor VA disalin!')),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.border, height: 32),
                          Text('Total Tagihan', style: AppTextStyles.bodySecondary),
                          const SizedBox(height: 8),
                          Text(
                            'Rp$formattedTariff',
                            style: AppTextStyles.h2,
                          ),
                        ],
                      ),
                    );
                  } else if (state is PaymentFailed) {
                    return Center(
                      child: Text(state.message, style: const TextStyle(color: Colors.red)),
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
                        const Icon(Icons.info_outline_rounded, color: AppColors.accentBlue, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Cara Membayar via Mobile Banking:',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _StepRow(step: '1', text: 'Buka aplikasi mobile banking Anda.'),
                    const _StepRow(step: '2', text: 'Pilih menu Transfer > Virtual Account.'),
                    const _StepRow(step: '3', text: 'Masukkan nomor VA di atas.'),
                    const _StepRow(step: '4', text: 'Pastikan nama penerima adalah "ParQr" dan jumlah bayar sesuai.'),
                    const _StepRow(step: '5', text: 'Selesaikan transaksi. Halaman ini akan otomatis diperbarui.'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(AppColors.accentBlue)),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Mendeteksi pembayaran...',
                      style: TextStyle(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue,
            ),
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}
