import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/domain/entities/parking_history_entity.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/presentation/blocs/history/history_cubit.dart';
import 'package:parqr/presentation/blocs/history/history_state.dart';
import 'package:parqr/presentation/widgets/app_bottom_nav.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HistoryCubit>()..fetchHistory(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat Parkir'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              if (state is HistoryLoading || state is HistoryInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is HistoryError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTextStyles.bodySecondary,
                  ),
                );
              }

              if (state is HistoryLoaded) {
                final history = state.history;
                if (history.isEmpty) {
                  return Center(
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
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HistoryCard(
                        data: item,
                        onTap: () {
                          // Determine statusBadgeType based on string
                          StatusBadgeType type = StatusBadgeType.neutral;
                          if (item.status.toLowerCase() == 'active' || item.status.toLowerCase() == 'booked') {
                            type = StatusBadgeType.active;
                          } else if (item.status.toLowerCase() == 'completed') {
                            type = StatusBadgeType.success;
                          }

                          // Calculate duration if applicable
                          String durationStr = '-';
                          if (item.exitTime != null) {
                            final diff = item.exitTime!.difference(item.entryTime);
                            final hours = diff.inHours;
                            final minutes = diff.inMinutes % 60;
                            durationStr = hours > 0 ? '$hours Jam $minutes Menit' : '$minutes Menit';
                          } else {
                            final diff = DateTime.now().difference(item.entryTime);
                            final hours = diff.inHours;
                            final minutes = diff.inMinutes % 60;
                            durationStr = hours > 0 ? '$hours Jam $minutes Menit' : '$minutes Menit';
                          }

                          // Date string formatting
                          final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(item.entryTime);

                          context.push(
                            RouteNames.historyDetail,
                            extra: {
                              'id': item.id,
                              'name': item.parkingLotName,
                              'address': item.parkingLotAddress,
                              'date': dateStr,
                              'duration': durationStr,
                              'vehicle': '${item.vehicleLicensePlate} (${item.vehicleName})',
                              'fare': item.totalFare != null ? 'Rp${item.totalFare!.toInt()}' : 'Rp0',
                              'statusLabel': item.status.toUpperCase(),
                              'statusType': type,
                              'isOngoing': item.isOngoing,
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }
              
              return const SizedBox.shrink();
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
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.data,
    required this.onTap,
  });

  final ParkingHistoryEntity data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Calculate duration
    String durationStr = '-';
    if (data.exitTime != null) {
      final diff = data.exitTime!.difference(data.entryTime);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      durationStr = hours > 0 ? '${hours}j ${minutes}m' : '${minutes}m';
    } else {
      final diff = DateTime.now().difference(data.entryTime);
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      durationStr = hours > 0 ? '${hours}j ${minutes}m' : '${minutes}m';
    }

    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(data.entryTime);
    
    StatusBadgeType type = StatusBadgeType.neutral;
    if (data.status.toLowerCase() == 'active' || data.status.toLowerCase() == 'booked') {
      type = StatusBadgeType.active;
    } else if (data.status.toLowerCase() == 'completed') {
      type = StatusBadgeType.success;
    }

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
                        data.parkingLotName,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    StatusBadge(label: data.status.toUpperCase(), type: type),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  dateStr,
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
                            durationStr,
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
                            data.vehicleLicensePlate,
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            data.isOngoing ? 'Berjalan' : (data.totalFare != null ? 'Rp${data.totalFare!.toInt()}' : 'Rp0'),
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
