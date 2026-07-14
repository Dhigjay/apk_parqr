import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/parking_session/active_session_state.dart';

class ActiveSessionCubit extends Cubit<ActiveSessionState> {
  ActiveSessionCubit() : super(ActiveSessionInitial());

  // Simulate subscribing to realtime updates for a parking session
  void subscribeToSession(String sessionId) {
    emit(ActiveSessionLoading());
    // In a real implementation, we would connect to Supabase Realtime here.
    // For now, we simulate receiving an active session update.
    Future.delayed(const Duration(seconds: 1), () {
      emit(ActiveSessionActive(
        sessionId: sessionId,
        startTime: DateTime.now().subtract(const Duration(minutes: 15)), // example 15 mins ago
        tariffPerHour: 5000.0,
      ));
    });
  }

  void endSession() {
    emit(ActiveSessionCompleted());
  }
}
