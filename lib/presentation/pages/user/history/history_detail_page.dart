import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.address,
    required this.date,
    required this.duration,
    required this.vehicle,
    required this.fare,
    required this.statusLabel,
    required this.statusType,
    required this.isOngoing,
  });

  final String id;
  final String name;
  final String address;
  final String date;
  final String duration;
  final String vehicle;
  final String fare;
  final String statusLabel;
  final StatusBadgeType statusType;
  final bool isOngoing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Status and site info header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOngoing
                          ? AppColors.accentBlue.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOngoing ? Icons.timelapse_rounded : Icons.check_circle_outline_rounded,
                      color: isOngoing ? AppColors.accentBlue : AppColors.success,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    address,
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  StatusBadge(label: statusLabel, type: statusType),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Struk Digital / Invoice Card
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STRUK DIGITAL',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentBlue,
                        ),
                      ),
                      Text(
                        'INV/202606/${id.toUpperCase()}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _DetailRow(label: 'Waktu Masuk', value: date),
                  _DetailRow(
                    label: 'Waktu Keluar',
                    value: isOngoing ? 'Masih parkir' : '23 Jun 2026, 14:49',
                  ),
                  _DetailRow(label: 'Durasi Total', value: duration),
                  _DetailRow(label: 'Kendaraan', value: vehicle),
                  _DetailRow(
                    label: 'Nomor Polisi',
                    value: '${vehicle.split(' ').first} ${vehicle.split(' ')[1]}',
                  ),
                  const Divider(color: AppColors.border, height: 24),
                  _DetailRow(
                    label: 'Metode Pembayaran',
                    value: isOngoing ? '-' : 'QRIS',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Bayar',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isOngoing ? 'Tarif Berjalan' : fare,
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

            // Action button
            if (isOngoing)
              AppButton(
                label: 'Lihat Detail Parkir Aktif',
                icon: Icons.map_rounded,
                onPressed: () {
                  context.push(RouteNames.activeParking);
                },
              )
            else
              AppButton(
                label: 'Kembali ke Riwayat',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  context.pop();
                },
              ),
          ],
        ),
      ),
    );
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
