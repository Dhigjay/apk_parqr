import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/core/utils/stopwatch_manager.dart';
import 'package:parqr/presentation/blocs/payment/payment_cubit.dart';
import 'package:parqr/presentation/blocs/payment/payment_state.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/form_feedback_banner.dart';
import 'package:parqr/presentation/widgets/loading_overlay.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({
    super.key,
    required this.sessionId,
    required this.startTime,
    required this.tariffPerHour,
  });

  final String sessionId;
  final DateTime startTime;
  final double tariffPerHour;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentCubit(),
      child: PaymentView(
        sessionId: sessionId,
        startTime: startTime,
        tariffPerHour: tariffPerHour,
      ),
    );
  }
}

class PaymentView extends StatefulWidget {
  const PaymentView({
    super.key,
    required this.sessionId,
    required this.startTime,
    required this.tariffPerHour,
  });

  final String sessionId;
  final DateTime startTime;
  final double tariffPerHour;

  @override
  State<PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String _selectedMethod = 'QRIS'; // 'QRIS' or 'Cash'
  late Duration _totalDuration;
  late double _totalTariff;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateTime();
        });
      }
    });
  }

  void _updateTime() {
    _totalDuration = StopwatchManager.calculateDuration(widget.startTime);
    _totalTariff = StopwatchManager.calculateTariff(_totalDuration, widget.tariffPerHour);
    
    if (_totalDuration.isNegative) {
      _totalDuration = Duration.zero;
      _totalTariff = 0.0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onPayPressed(BuildContext context) {
    final cubit = context.read<PaymentCubit>();
    if (_selectedMethod == 'QRIS') {
      // Go to QRIS page first
      context.push(
        '${RouteNames.payment}/qris', // We will register it or sub-route
        extra: {
          'sessionId': widget.sessionId,
          'totalTariff': _totalTariff,
          'totalDuration': _totalDuration.inSeconds,
        },
      );
    } else {
      // Cash payment via cubit
      cubit.processCashPayment();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      listener: (context, state) {
        if (state is PaymentSuccess) {
          // Cash payment confirmed by operator simulation
          context.go(
            RouteNames.exitQr,
            extra: {
              'exitQrPayload': state.exitQrPayload,
              'tariff': _totalTariff,
              'durationInSeconds': _totalDuration.inSeconds,
              'method': 'Cash',
            },
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PaymentProcessing;
        final isAwaiting = state is PaymentAwaitingVerification;
        final errorMsg = state is PaymentFailed ? state.message : null;

        return LoadingOverlay(
          isLoading: isLoading,
          message: 'Memproses pembayaran...',
          child: Scaffold(
              appBar: AppBar(
                title: const Text('Pembayaran Parkir'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: (isLoading || isAwaiting) ? null : () => context.pop(),
                ),
              ),
              body: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Lokasi & Durasi summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ParQr Sudirman Hub', style: AppTextStyles.h3),
                          const SizedBox(height: 14),
                          _DetailRow(
                            label: 'Waktu Masuk',
                            value: _formatDateTime(widget.startTime),
                          ),
                          _DetailRow(
                            label: 'Durasi Parkir',
                            value: StopwatchManager.formatDuration(_totalDuration),
                          ),
                          const _DetailRow(
                            label: 'Kendaraan',
                            value: 'B 1234 QR',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Rincian Biaya
                    Text('Rincian Biaya', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _FareRow(
                            label: 'Biaya Parkir (per jam)',
                            value: 'Rp${widget.tariffPerHour.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                          ),
                          const Divider(color: AppColors.border, height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Bayar',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.accentBlue,
                                ),
                              ),
                              Text(
                                'Rp${_totalTariff.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.accentBlue,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Metode Pembayaran
                    Text('Metode Pembayaran', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    _PaymentMethodTile(
                      title: 'QRIS (Otomatis & Realtime)',
                      subtitle: 'Bayar cashless via Gopay, OVO, Dana, LinkAja',
                      icon: Icons.qr_code_2_rounded,
                      isSelected: _selectedMethod == 'QRIS',
                      onTap: (isLoading || isAwaiting)
                          ? null
                          : () => setState(() => _selectedMethod = 'QRIS'),
                    ),
                    const SizedBox(height: 10),
                    _PaymentMethodTile(
                      title: 'Bayar Cash ke Operator',
                      subtitle: 'Lakukan pembayaran manual ke pos penjagaan',
                      icon: Icons.payments_rounded,
                      isSelected: _selectedMethod == 'Cash',
                      onTap: (isLoading || isAwaiting)
                          ? null
                          : () => setState(() => _selectedMethod = 'Cash'),
                    ),
                    const SizedBox(height: 24),

                    if (isAwaiting) ...[
                      const Center(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation(AppColors.warning),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Menunggu Operator memverifikasi pembayaran...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (errorMsg != null) ...[
                      FormFeedbackBanner(
                        message: errorMsg,
                        type: FormFeedbackType.error,
                      ),
                      const SizedBox(height: 20),
                    ],

                    AppButton(
                      label: _selectedMethod == 'QRIS' ? 'Bayar Sekarang' : 'Minta Verifikasi Operator',
                      icon: _selectedMethod == 'QRIS' ? Icons.qr_code_rounded : Icons.person_search_rounded,
                      isLoading: isLoading,
                      onPressed: isAwaiting ? null : () => _onPayPressed(context),
                    ),
                  ],
                ),
              ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final day = dt.day;
    final month = monthNames[dt.month - 1];
    final year = dt.year;
    final hour = twoDigits(dt.hour);
    final min = twoDigits(dt.minute);
    return "$day $month $year, $hour:$min";
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodySecondary),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FareRow extends StatelessWidget {
  const _FareRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTextStyles.bodySecondary),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.05) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.accentBlue : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                  size: 26,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.accentBlue : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isSelected ? AppColors.accentBlue : AppColors.border,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
