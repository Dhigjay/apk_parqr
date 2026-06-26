import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/blocs/operator/operator_dashboard_cubit.dart';
import 'package:parqr/presentation/blocs/operator/operator_dashboard_state.dart';
import 'widgets/stats_row_widget.dart';
import 'widgets/active_vehicle_card.dart';

class OperatorDashboardPage extends StatefulWidget {
  const OperatorDashboardPage({super.key});

  @override
  State<OperatorDashboardPage> createState() => _OperatorDashboardPageState();
}

class _OperatorDashboardPageState extends State<OperatorDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data when entering
    context.read<OperatorDashboardCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.lotManagement),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan Lahan',
          ),
          IconButton(
            onPressed: () {
              // Simulate logout
              context.go(RouteNames.login);
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<OperatorDashboardCubit, OperatorDashboardState>(
        builder: (context, state) {
          if (state is OperatorDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OperatorDashboardError) {
            return Center(
              child: Text(
                state.message,
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            );
          } else if (state is OperatorDashboardLoaded) {
            final stats = state.stats;
            final vehicles = state.activeVehicles;

            return RefreshIndicator(
              onRefresh: () => context.read<OperatorDashboardCubit>().loadDashboard(),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Ringkasan Hari Ini',
                    style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  StatsRowWidget(
                    vehiclesInToday: stats.vehiclesInToday,
                    vehiclesActiveNow: stats.vehiclesActiveNow,
                    revenueToday: stats.revenueToday.toDouble(),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kendaraan Aktif (${vehicles.length})',
                        style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => context.read<OperatorDashboardCubit>().loadDashboard(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Segarkan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (vehicles.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.directions_car_filled_outlined,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tidak ada kendaraan aktif saat ini.',
                            style: AppTextStyles.bodySecondary,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...vehicles.map(
                      (vehicle) => ActiveVehicleCard(
                        vehicleName: vehicle.vehicleName,
                        licensePlate: vehicle.licensePlate,
                        checkInTime: vehicle.checkInTime,
                        floor: vehicle.floor,
                        currentTariff: vehicle.currentTariff.toDouble(),
                        onTap: () {
                          // Navigate to Scanned Vehicle Detail Page
                          context.push(
                            '/scanned-vehicle',
                            extra: {
                              'sessionId': vehicle.sessionId,
                              'vehicleName': vehicle.vehicleName,
                              'licensePlate': vehicle.licensePlate,
                              'checkInTime': vehicle.checkInTime.toIso8601String(),
                              'floor': vehicle.floor,
                              'currentTariff': vehicle.currentTariff.toDouble(),
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          }
          return const Center(child: Text('Memulai...'));
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push(RouteNames.qrScanner),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
          label: Text(
            'Scan QR',
            style: AppTextStyles.button.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
