import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/core/utils/qr_validator.dart';
import 'package:parqr/presentation/blocs/operator/operator_dashboard_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OperatorDashboardCubit extends Cubit<OperatorDashboardState> {
  OperatorDashboardCubit() : super(OperatorDashboardInitial());

  Future<void> loadDashboard() async {
    emit(OperatorDashboardLoading());
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;

      if (currentUser == null) {
        throw Exception('Operator belum login.');
      }

      final lotRows = await supabase
          .from('parking_lots')
          .select('id')
          .eq('owner_id', currentUser.id);
      final lotIds = (lotRows as List<dynamic>)
          .map((row) => row['id']?.toString())
          .whereType<String>()
          .toList();

      if (lotIds.isEmpty) {
        emit(const OperatorDashboardLoaded(
          stats: OperatorStats(
            vehiclesInToday: 0,
            vehiclesActiveNow: 0,
            revenueToday: 0,
          ),
          activeVehicles: [],
        ));
        return;
      }

      final sessionsResponse = await supabase
          .from('parking_sessions')
          .select('''
            id,
            status,
            entered_at,
            created_at,
            lot_id,
            vehicle_id,
            vehicles ( brand, model, plate_number ),
            parking_lots ( name ),
            parking_slots ( floor_number, code )
          ''')
          .filter('lot_id', 'in', '(${lotIds.join(',')})')
          .order('created_at', ascending: false);

      final sessions = sessionsResponse as List<dynamic>;
      final now = DateTime.now();

      final activeVehicles = sessions
          .where((row) => _isCurrentlyParked(row as Map<String, dynamic>))
          .map((row) => _mapSessionToVehicle(row as Map<String, dynamic>))
          .toList();

      final vehiclesInToday = sessions.where((row) {
        final session = row as Map<String, dynamic>;
        final checkIn = _extractCheckInTime(session);
        return _isSameDay(checkIn, now);
      }).length;

      emit(OperatorDashboardLoaded(
        stats: OperatorStats(
          vehiclesInToday: vehiclesInToday,
          vehiclesActiveNow: activeVehicles.length,
          revenueToday: 0,
        ),
        activeVehicles: activeVehicles,
      ));
    } catch (e) {
      emit(OperatorDashboardError('Gagal memuat data: ${e.toString()}'));
    }
  }

  Future<void> processScannedQr(
    String rawData, {
    required String expectedType,
  }) async {
    final result = QrValidator.validate(rawData, expectedType: expectedType);

    if (!result.isValid) {
      emit(OperatorQrScanError(result.errorMessage ?? 'QR tidak valid'));
      return;
    }

    final payload = result.payload!;

    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Operator belum login.');
      }

      final lotRows = await supabase
          .from('parking_lots')
          .select('id')
          .eq('owner_id', currentUser.id);
      final lotIds = (lotRows as List<dynamic>)
          .map((row) => row['id']?.toString())
          .whereType<String>()
          .toList();

      if (lotIds.isEmpty) {
        emit(const OperatorQrScanError(
            'Belum ada lahan parkir yang Anda kelola.'));
        return;
      }

      final sessionResponse = await supabase
          .from('parking_sessions')
          .select('''
            id,
            status,
            entered_at,
            created_at,
            lot_id,
            vehicles ( brand, model, plate_number ),
            parking_lots ( name ),
            parking_slots ( floor_number, code )
          ''')
          .eq('id', payload.sessionId)
          .filter('lot_id', 'in', '(${lotIds.join(',')})')
          .maybeSingle();

      if (sessionResponse == null) {
        emit(const OperatorQrScanError(
            'Sesi parkir tidak ditemukan untuk lahan Anda.'));
        return;
      }

      final now = DateTime.now().toIso8601String();
      if (expectedType == 'entry') {
        await supabase
            .from('parking_sessions')
            .update({'status': 'active', 'entered_at': now}).eq(
                'id', payload.sessionId);
      } else {
        await supabase
            .from('parking_sessions')
            .update({'status': 'completed', 'exited_at': now}).eq(
                'id', payload.sessionId);
      }

      emit(OperatorQrScanSuccess(
        message: expectedType == 'entry'
            ? 'Kendaraan berhasil masuk'
            : 'Kendaraan berhasil keluar',
        vehicle: _mapSessionToVehicle(sessionResponse),
      ));

      await loadDashboard();
    } catch (e) {
      emit(OperatorDashboardError('Gagal memproses QR: ${e.toString()}'));
    }
  }

  Future<void> verifyCashPayment(String sessionId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase
          .from('payments')
          .update({'status': 'paid'}).eq('session_id', sessionId);
      emit(OperatorCashVerified());
      await loadDashboard();
    } catch (e) {
      emit(OperatorDashboardError(
          'Gagal verifikasi pembayaran: ${e.toString()}'));
    }
  }

  bool _isCurrentlyParked(Map<String, dynamic> session) {
    final status = session['status']?.toString().toLowerCase();
    final enteredAt = session['entered_at']?.toString();

    return status == 'active' ||
        status == 'payment_pending' ||
        status == 'checkout_requested' ||
        (status == 'booked' && enteredAt != null && enteredAt.isNotEmpty);
  }

  DateTime _extractCheckInTime(Map<String, dynamic> session) {
    final enteredAt = session['entered_at']?.toString();
    final createdAt = session['created_at']?.toString();

    if (enteredAt != null && enteredAt.isNotEmpty) {
      return DateTime.tryParse(enteredAt) ?? DateTime.now();
    }

    if (createdAt != null && createdAt.isNotEmpty) {
      return DateTime.tryParse(createdAt) ?? DateTime.now();
    }

    return DateTime.now();
  }

  bool _isSameDay(DateTime value, DateTime compareTo) {
    return value.year == compareTo.year &&
        value.month == compareTo.month &&
        value.day == compareTo.day;
  }

  ActiveVehicle _mapSessionToVehicle(Map<String, dynamic> session) {
    final vehicleData = session['vehicles'] as Map<String, dynamic>? ?? {};
    final lotData = session['parking_lots'] as Map<String, dynamic>? ?? {};
    final slotData = session['parking_slots'] as Map<String, dynamic>? ?? {};
    final checkInTime = _extractCheckInTime(session);

    final vehicleName = [
      vehicleData['brand']?.toString(),
      vehicleData['model']?.toString(),
    ].where((value) => value != null && value.isNotEmpty).join(' ').trim();

    final plateNumber = vehicleData['plate_number']?.toString() ?? '-';
    final lotName = lotData['name']?.toString();
    final floorNumber = slotData['floor_number'];
    final floorLabel = floorNumber != null
        ? 'Lantai $floorNumber'
        : (lotName != null && lotName.isNotEmpty ? lotName : 'Lantai 1');

    final status = session['status']?.toString().toLowerCase();
    final statusLabel = status == 'payment_pending'
        ? 'Menunggu Pembayaran'
        : status == 'checkout_requested'
            ? 'Checkout Diminta'
            : status == 'completed'
                ? 'Selesai'
                : 'Aktif';

    return ActiveVehicle(
      sessionId: session['id'].toString(),
      vehicleName: vehicleName.isNotEmpty ? vehicleName : 'Kendaraan',
      licensePlate: plateNumber,
      checkInTime: checkInTime,
      floor: floorLabel,
      currentTariff: 0,
      awaitingCashVerification: status == 'payment_pending',
      statusLabel: statusLabel,
    );
  }
}
