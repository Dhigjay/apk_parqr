import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/qr_display_card.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class QrEntryPage extends StatelessWidget {
  const QrEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final issuedAt = DateTime(2026, 6, 19, 9, 30);

    return Scaffold(
      appBar: AppBar(title: const Text('QR Masuk')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const StatusBadge(
              label: 'Menunggu scan operator',
              type: StatusBadgeType.pending,
            ),
            const SizedBox(height: 18),
            QrDisplayCard(
              data:
                  'parqr://entry?session_id=demo-session-001&type=entry&issued_at=${issuedAt.toIso8601String()}',
              title: 'ParQr Sudirman Hub',
              subtitle: 'Tunjukkan QR ini ke operator saat masuk area parkir.',
              size: 230,
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  _InfoRow(label: 'Waktu Booking', value: '19 Jun 2026, 09:30'),
                  _InfoRow(label: 'Kendaraan', value: 'B 1234 QR'),
                  _InfoRow(label: 'Slot', value: 'L2-B12'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AppButton(
              label: AppStrings.saveLocation,
              icon: Icons.my_location_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            Text(
              'QR berlaku 24 jam selama belum dipakai. Stopwatch tarif mulai setelah operator berhasil scan QR masuk.',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
