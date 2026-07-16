import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/blocs/parking_session/active_session_cubit.dart';
import 'package:parqr/presentation/blocs/parking_session/active_session_state.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';
import 'package:parqr/presentation/pages/user/active_parking/widgets/stopwatch_widget.dart';

class ActiveParkingPage extends StatelessWidget {
  const ActiveParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Terima data dari QrEntryPage via route extra
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    final sessionId = extra?['sessionId'] as String? ?? 'demo-session-001';
    final parkingLotName =
        extra?['parkingLotName'] as String? ?? 'ParQr Parking';
    final vehiclePlate = extra?['vehiclePlate'] as String? ?? 'B 1234 QR';
    final vehicleName = extra?['vehicleName'] as String? ?? '-';
    final slot = extra?['slot'] as String? ?? '-';
    final tariffPerHour = extra?['tariffPerHour'] as double? ?? 5000.0;
    final startTimeStr = extra?['startTime'] as String?;
    final startTime = startTimeStr != null
        ? DateTime.tryParse(startTimeStr) ?? DateTime.now()
        : DateTime.now();

    return BlocProvider(
      create: (_) => ActiveSessionCubit()
        ..loadSession(
          sessionId: sessionId,
          startTime: startTime,
          tariffPerHour: tariffPerHour,
        ),
      child: ActiveParkingView(
        parkingLotName: parkingLotName,
        vehiclePlate: vehiclePlate,
        vehicleName: vehicleName,
        slot: slot,
      ),
    );
  }
}

class ActiveParkingView extends StatelessWidget {
  const ActiveParkingView({
    super.key,
    required this.parkingLotName,
    required this.vehiclePlate,
    required this.vehicleName,
    required this.slot,
  });

  final String parkingLotName;
  final String vehiclePlate;
  final String vehicleName;
  final String slot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkir Aktif'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: BlocBuilder<ActiveSessionCubit, ActiveSessionState>(
          builder: (context, state) {
            if (state is ActiveSessionInitial ||
                state is ActiveSessionLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                ),
              );
            }

            if (state is ActiveSessionActive) {
              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(parkingLotName,
                            style: AppTextStyles.h2.copyWith(fontSize: 22)),
                        const SizedBox(height: 8),
                        const StatusBadge(
                          label: 'DURASI PARKIR',
                          type: StatusBadgeType.active,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stopwatch
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.08),
                          blurRadius: 32,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StopwatchWidget(startTime: state.startTime),
                        const SizedBox(height: 12),
                        Text(
                          'Tarif: Rp${state.tariffPerHour.toInt()} / jam',
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Info Kendaraan
                  Text('Info Kendaraan', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.directions_car_filled_rounded,
                            color: AppColors.accentBlue,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehiclePlate,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(vehicleName,
                                  style: AppTextStyles.bodySecondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Lokasi Slot
                  Text('Lokasi Parkir', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.accentPurple,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Slot $slot',
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Keluar Parkir
                  AppButton(
                    label: 'Keluar Parkir',
                    icon: Icons.exit_to_app_rounded,
                    onPressed: () {
                      context.push(
                        RouteNames.payment,
                        extra: {
                          'sessionId': state.sessionId,
                          'startTime': state.startTime.toIso8601String(),
                          'tariffPerHour': state.tariffPerHour,
                          'parkingLotName': parkingLotName,
                          'vehiclePlate': vehiclePlate,
                          'vehicleName': vehicleName,
                        },
                      );
                    },
                  ),
                ],
              );
            }

            if (state is ActiveSessionCompleted) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: AppColors.success, size: 64),
                    const SizedBox(height: 16),
                    Text('Sesi Parkir Selesai', style: AppTextStyles.h2),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Kembali ke Home',
                      onPressed: () => context.go(RouteNames.home),
                    ),
                  ],
                ),
              );
            }

            final message = state is ActiveSessionError
                ? state.message
                : 'Terjadi kesalahan.';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.error, size: 64),
                    const SizedBox(height: 16),
                    Text(message,
                        style: AppTextStyles.body, textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
