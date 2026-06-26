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
import 'widgets/stopwatch_widget.dart';

class ActiveParkingPage extends StatelessWidget {
  const ActiveParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActiveSessionCubit()..subscribeToSession('demo-session-001'),
      child: const ActiveParkingView(),
    );
  }
}

class ActiveParkingView extends StatelessWidget {
  const ActiveParkingView({super.key});

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
            if (state is ActiveSessionInitial || state is ActiveSessionLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
                ),
              );
            } else if (state is ActiveSessionActive) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'ParQr Sudirman Hub',
                          style: AppTextStyles.h2.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        const StatusBadge(
                          label: 'DURASI PARKIR',
                          type: StatusBadgeType.active,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Stopwatch Display
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
                          'Tarif berjalan: Rp5.000 / jam',
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
                                'B 1234 QR',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Honda Vario 125 (Motor)',
                                style: AppTextStyles.bodySecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Lokasi & Peta Mock
                  Text('Lokasi Parkir', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.accentPurple,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lantai 2 - Slot B12',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Mock Map Area
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Grid pattern mockup
                              Opacity(
                                opacity: 0.15,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 6,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                  ),
                                  itemCount: 24,
                                  itemBuilder: (context, index) => Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                              // Marker
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.my_location_rounded,
                                    color: AppColors.accentBlue,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgCard,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Text(
                                      'B12',
                                      style: AppTextStyles.caption.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.accentBlue,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Button Checkout
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
                        },
                      );
                    },
                  ),
                ],
              );
            } else if (state is ActiveSessionCompleted) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.success,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sesi Parkir Telah Selesai',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Kembali Ke Home',
                      onPressed: () => context.go(RouteNames.home),
                    ),
                  ],
                ),
              );
            } else {
              final message = state is ActiveSessionError ? state.message : 'Terjadi kesalahan.';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: AppTextStyles.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
