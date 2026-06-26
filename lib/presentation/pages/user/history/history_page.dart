import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/widgets/app_bottom_nav.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const List<_HistoryItemData> _mockHistory = [
    _HistoryItemData(
      id: 'session-001',
      name: 'ParQr Sudirman Hub',
      address: 'Jl. Jend. Sudirman No. 12, Jakarta Pusat',
      date: '23 Jun 2026, 12:45',
      duration: '15 Menit',
      vehicle: 'B 1234 QR (Honda Vario)',
      fare: 'Rp5.000',
      statusLabel: 'Aktif',
      statusType: StatusBadgeType.active,
      isOngoing: true,
    ),
    _HistoryItemData(
      id: 'session-002',
      name: 'Mall Atrium Parking',
      address: 'Jl. Senen Raya No. 135, Jakarta Pusat',
      date: '19 Jun 2026, 14:10',
      duration: '2 Jam 4 Menit',
      vehicle: 'B 1234 QR (Honda Vario)',
      fare: 'Rp14.000',
      statusLabel: 'Selesai',
      statusType: StatusBadgeType.success,
      isOngoing: false,
    ),
    _HistoryItemData(
      id: 'session-003',
      name: 'Kemang Night Park',
      address: 'Jl. Kemang Selatan VIII, Jakarta Selatan',
      date: '15 Jun 2026, 19:30',
      duration: '1 Jam 45 Menit',
      vehicle: 'B 1234 QR (Honda Vario)',
      fare: 'Rp12.000',
      statusLabel: 'Selesai',
      statusType: StatusBadgeType.success,
      isOngoing: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Parkir'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _mockHistory.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.textSecondary,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada riwayat parkir',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _mockHistory.length,
                itemBuilder: (context, index) {
                  final item = _mockHistory[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _HistoryCard(
                      data: item,
                      onTap: () {
                        context.push(
                          RouteNames.historyDetail,
                          extra: {
                            'id': item.id,
                            'name': item.name,
                            'address': item.address,
                            'date': item.date,
                            'duration': item.duration,
                            'vehicle': item.vehicle,
                            'fare': item.fare,
                            'statusLabel': item.statusLabel,
                            'statusType': item.statusType,
                            'isOngoing': item.isOngoing,
                          },
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            context.go(RouteNames.home);
          } else if (index == 2) {
            context.go(RouteNames.profile);
          }
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.data,
    required this.onTap,
  });

  final _HistoryItemData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.isOngoing
              ? AppColors.accentBlue.withValues(alpha: 0.4)
              : AppColors.border,
          width: data.isOngoing ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data.name,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(label: data.statusLabel, type: data.statusType),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data.date,
                  style: AppTextStyles.caption,
                ),
                const Divider(color: AppColors.border, height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Durasi', style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(
                            data.duration,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kendaraan', style: AppTextStyles.caption),
                          const SizedBox(height: 2),
                          Text(
                            data.vehicle.split(' ').first,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Total Tarif',
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.right),
                          const SizedBox(height: 2),
                          Text(
                            data.isOngoing ? 'Berjalan' : data.fare,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: data.isOngoing
                                  ? AppColors.accentBlue
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryItemData {
  const _HistoryItemData({
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
}
