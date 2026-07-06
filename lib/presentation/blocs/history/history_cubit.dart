import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/domain/repositories/i_parking_session_repository.dart';
import 'package:parqr/presentation/blocs/history/history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final IParkingSessionRepository _sessionRepository;
  final SupabaseClient _supabaseClient;

  HistoryCubit({
    required IParkingSessionRepository sessionRepository,
    required SupabaseClient supabaseClient,
  })  : _sessionRepository = sessionRepository,
        _supabaseClient = supabaseClient,
        super(HistoryInitial());

  Future<void> fetchHistory() async {
    emit(HistoryLoading());
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        emit(const HistoryError('User not logged in'));
        return;
      }
      
      final history = await _sessionRepository.getUserHistory(user.id);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
