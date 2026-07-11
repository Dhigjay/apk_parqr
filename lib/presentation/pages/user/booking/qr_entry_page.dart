import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/qr_display_card.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class QrEntryPage extends StatelessWidget {
  const QrEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Terima data dari BookingPage via route extra
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final sessionId = extra?['sessionId'] as String? ?? '';
    final entryQrPayload = extra?['entryQrPayload'] as String? ?? sessionId;
    final parkingLotName =
        extra?['parkingLotName'] as String? ?? 'ParQr Parking';
    final vehiclePlate = extra?['vehiclePlate'] as String? ?? '-';
    final vehicleName = extra?['vehicleName'] as String? ?? '-';
    final slot = extra?['slot'] as String? ?? '-';
    final tariffPerHour = extra?['tariffPerHour'] as double? ?? 5000.0;
    final bookedAtStr = extra?['bookedAt'] as String?;
    final bookedAt =
        bookedAtStr != null ? DateTime.tryParse(bookedAtStr) : DateTime.now();

    String _formatDateTime(DateTime? dt) {
      if (dt == null) return '-';
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

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
              data: entryQrPayload,
              title: parkingLotName,
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
              child: Column(
                children: [
                  _InfoRow(
                      label: 'Waktu Booking', value: _formatDateTime(bookedAt)),
                  _InfoRow(
                      label: 'Kendaraan',
                      value: '$vehiclePlate ($vehicleName)'),
                  _InfoRow(label: 'Slot', value: slot),
                  _InfoRow(
                    label: 'Tarif',
                    value: 'Rp${tariffPerHour.toInt()}/jam',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AppButton(
              label: AppStrings.saveLocation,
              icon: Icons.my_location_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            // Tombol simulasi: di production ini digantikan oleh scan operator
            AppButton(
              label: 'Simulasi Scan Masuk (Operator)',
              icon: Icons.login_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                context.go(
                  RouteNames.activeParking,
                  extra: {
                    'sessionId': sessionId,
                    'parkingLotName': parkingLotName,
                    'vehiclePlate': vehiclePlate,
                    'vehicleName': vehicleName,
                    'slot': slot,
                    'tariffPerHour': tariffPerHour,
                    // startTime diisi saat scan operator — simulasi pakai now
                    'startTime': DateTime.now().toIso8601String(),
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'QR berlaku 24 jam. Stopwatch tarif mulai setelah operator scan QR masuk.',
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
  const _InfoRow({required this.label, required this.value});
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
