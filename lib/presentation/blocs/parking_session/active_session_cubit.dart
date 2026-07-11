import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/parking_session/active_session_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActiveSessionCubit extends Cubit<ActiveSessionState> {
  ActiveSessionCubit() : super(ActiveSessionInitial());

  /// Dipanggil dari ActiveParkingPage dengan data nyata dari route extra.
  /// Jika sessionId adalah UUID valid, ambil data aktual dari Supabase.
  /// Jika bukan (mode simulasi), gunakan data yang diteruskan langsung.
  void loadSession({
    required String sessionId,
    required DateTime startTime,
    required double tariffPerHour,
  }) {
    emit(ActiveSessionLoading());

    // Validasi: pastikan startTime tidak di masa depan (clock skew)
    final now = DateTime.now();
    final safeStartTime = startTime.isAfter(now) ? now : startTime;

    emit(ActiveSessionActive(
      sessionId: sessionId,
      startTime: safeStartTime,
      tariffPerHour: tariffPerHour,
    ));
  }

  /// Versi dengan fetch dari Supabase — dipakai jika hanya punya sessionId.
  Future<void> subscribeToSession(String sessionId) async {
    emit(ActiveSessionLoading());

    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    if (!uuidRegex.hasMatch(sessionId)) {
      // Mode simulasi — tidak ada data nyata
      emit(ActiveSessionActive(
        sessionId: sessionId,
        startTime: DateTime.now(),
        tariffPerHour: 5000.0,
      ));
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('parking_sessions')
          .select('id, entered_at, lot_id, parking_lots(price_per_hour)')
          .eq('id', sessionId)
          .maybeSingle();

      if (response == null) {
        emit(const ActiveSessionError('Sesi parkir tidak ditemukan.'));
        return;
      }

      final enteredAtStr = response['entered_at'] as String?;
      final enteredAt = enteredAtStr != null
          ? DateTime.tryParse(enteredAtStr) ?? DateTime.now()
          : DateTime.now();

      final lotData = response['parking_lots'] as Map<String, dynamic>?;
      final tariff = lotData != null
          ? (lotData['price_per_hour'] as num).toDouble()
          : 5000.0;

      emit(ActiveSessionActive(
        sessionId: sessionId,
        startTime: enteredAt,
        tariffPerHour: tariff,
      ));
    } catch (e) {
      emit(ActiveSessionError('Gagal memuat sesi: $e'));
    }
  }

  void endSession() {
    emit(ActiveSessionCompleted());
  }
}
