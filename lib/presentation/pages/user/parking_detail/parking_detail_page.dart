import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class ParkingDetailPage extends StatelessWidget {
  const ParkingDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Parkir')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const _MapThumbnail(),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ParQr Sudirman Hub', style: AppTextStyles.h2),
                      const SizedBox(height: 8),
                      Text(
                        'Jl. Jend. Sudirman No. 12, Jakarta Pusat',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ),
                ),
                const StatusBadge(
                  label: 'Tersedia',
                  type: StatusBadgeType.active,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.event_seat_outlined,
                    label: 'Kapasitas',
                    value: '24/80',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.payments_outlined,
                    label: 'Tarif',
                    value: 'Rp5.000/jam',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.layers_outlined,
                    label: 'Lantai',
                    value: '3 lantai',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.near_me_outlined,
                    label: 'Jarak',
                    value: '350 m',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Info Lantai', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            const _FloorAvailabilityTile(
              floor: 'Lantai 1',
              slots: '8 slot tersedia',
              type: StatusBadgeType.pending,
            ),
            const _FloorAvailabilityTile(
              floor: 'Lantai 2',
              slots: '10 slot tersedia',
              type: StatusBadgeType.active,
            ),
            const _FloorAvailabilityTile(
              floor: 'Basement',
              slots: '6 slot tersedia',
              type: StatusBadgeType.active,
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Pesan Parkir',
              icon: Icons.qr_code_2_rounded,
              onPressed: () => context.push(RouteNames.booking),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapThumbnail extends StatelessWidget {
  const _MapThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapPatternPainter(),
            ),
          ),
          const Center(
            child: Icon(
              Icons.location_pin,
              color: AppColors.error,
              size: 44,
            ),
          ),
          Positioned(
            left: 14,
            bottom: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Text('Dark map thumbnail', style: AppTextStyles.caption),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accentBlue, size: 22),
          const SizedBox(height: 12),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _FloorAvailabilityTile extends StatelessWidget {
  const _FloorAvailabilityTile({
    required this.floor,
    required this.slots,
    required this.type,
  });

  final String floor;
  final String slots;
  final StatusBadgeType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers_rounded, color: AppColors.accentPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(floor,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(slots, style: AppTextStyles.caption),
              ],
            ),
          ),
          StatusBadge(label: 'Open', type: type),
        ],
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final accentPaint = Paint()
      ..color = AppColors.accentBlue.withValues(alpha: 0.35)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.24),
        Offset(size.width, size.height * 0.1), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.72),
        Offset(size.width, size.height * 0.48), roadPaint);
    canvas.drawLine(Offset(size.width * 0.22, 0),
        Offset(size.width * 0.72, size.height), accentPaint);
    canvas.drawLine(Offset(size.width * 0.76, 0),
        Offset(size.width * 0.28, size.height), roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
