import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/core/utils/stopwatch_manager.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/qr_display_card.dart';

class ExitQrPage extends StatelessWidget {
  const ExitQrPage({
    super.key,
    required this.exitQrPayload,
    required this.tariff,
    required this.durationInSeconds,
    required this.method,
  });

  final String exitQrPayload;
  final double tariff;
  final int durationInSeconds;
  final String method;

  @override
  Widget build(BuildContext context) {
    final formattedTariff = tariff.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    final duration = Duration(seconds: durationInSeconds);
    final formattedDuration = StopwatchManager.formatDuration(duration);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Keluar'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            // Success Indicator
            const Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 64,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Pembayaran Sukses!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Exit QR Card
            QrDisplayCard(
              data: 'parqr://exit?payload=$exitQrPayload',
              title: 'ParQr Sudirman Hub',
              subtitle: 'Scan QR ini pada pos keluar parkir.',
              size: 200,
            ),
            const SizedBox(height: 24),

            // Struk Digital / Receipt Summary
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
                  Text(
                    'Rincian Transaksi',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _ReceiptRow(label: 'Metode Pembayaran', value: method),
                  _ReceiptRow(label: 'Durasi Parkir', value: formattedDuration),
                  _ReceiptRow(label: 'Waktu Keluar', value: _formatDateTime(DateTime.now())),
                  const Divider(color: AppColors.border, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Bayar',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Rp$formattedTariff',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Back to Home Button
            AppButton(
              label: 'Kembali Ke Home',
              icon: Icons.home_rounded,
              onPressed: () => context.go(RouteNames.home),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
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

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary.copyWith(fontSize: 13)),
          Text(value, style: AppTextStyles.body.copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
