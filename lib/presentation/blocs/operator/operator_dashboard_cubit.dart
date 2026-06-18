import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/qr_validator.dart';
import 'operator_dashboard_state.dart';

class OperatorDashboardCubit extends Cubit<OperatorDashboardState> {
  OperatorDashboardCubit() : super(OperatorDashboardInitial());

  /// Load dashboard stats and active vehicle list.
  /// Simulates a realtime subscription — swap Future.delayed with Supabase Realtime.
  Future<void> loadDashboard() async {
    emit(OperatorDashboardLoading());
    try {
      // Simulated fetch — replace with actual Supabase queries
      await Future.delayed(const Duration(milliseconds: 500));

      const stats = OperatorStats(
        vehiclesInToday: 24,
        vehiclesActiveNow: 7,
        revenueToday: 185000,
      );

      final activeVehicles = [
        ActiveVehicle(
          sessionId: 'session-001',
          vehicleName: 'Toyota Avanza',
          licensePlate: 'B 1234 XY',
          checkInTime: DateTime.now().subtract(const Duration(hours: 2)),
          floor: 'Lantai 1',
          currentTariff: 10000,
        ),
        ActiveVehicle(
          sessionId: 'session-002',
          vehicleName: 'Honda Beat',
          licensePlate: 'D 5678 AB',
          checkInTime: DateTime.now().subtract(const Duration(minutes: 45)),
          floor: 'Lantai 2',
          currentTariff: 5000,
        ),
      ];

      emit(OperatorDashboardLoaded(stats: stats, activeVehicles: activeVehicles));
    } catch (e) {
      emit(OperatorDashboardError('Gagal memuat data: ${e.toString()}'));
    }
  }

  /// Processes a scanned QR string — validates type, expiry, and operator ownership.
  Future<void> processScannedQr(String rawData, {required String expectedType}) async {
    final result = QrValidator.validate(rawData, expectedType: expectedType);

    if (!result.isValid) {
      emit(OperatorQrScanError(result.errorMessage ?? 'QR tidak valid'));
      return;
    }

    final payload = result.payload!;

    // Simulate confirming the session belongs to this operator's lot
    await Future.delayed(const Duration(milliseconds: 300));

    // Emit success with a dummy vehicle for now
    emit(OperatorQrScanSuccess(
      message: expectedType == 'entry' ? 'Kendaraan berhasil masuk' : 'Kendaraan berhasil keluar',
      vehicle: ActiveVehicle(
        sessionId: payload.sessionId,
        vehicleName: 'Kendaraan Terdaftar',
        licensePlate: 'SCANNED-PLATE',
        checkInTime: DateTime.now(),
        floor: 'Lantai 1',
        currentTariff: 0,
      ),
    ));

    // Reload dashboard after scan
    await loadDashboard();
  }

  /// Verifies cash payment for a given session.
  Future<void> verifyCashPayment(String sessionId) async {
    try {
      // Simulate API call to verify payment
      await Future.delayed(const Duration(milliseconds: 500));
      emit(OperatorCashVerified());
      // Reload dashboard to reflect updated list
      await loadDashboard();
    } catch (e) {
      emit(OperatorDashboardError('Gagal verifikasi pembayaran: ${e.toString()}'));
    }
  }
}
