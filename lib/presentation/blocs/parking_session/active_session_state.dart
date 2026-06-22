import 'package:equatable/equatable.dart';

abstract class ActiveSessionState extends Equatable {
  const ActiveSessionState();

  @override
  List<Object?> get props => [];
}

class ActiveSessionInitial extends ActiveSessionState {}

class ActiveSessionLoading extends ActiveSessionState {}

class ActiveSessionActive extends ActiveSessionState {
  final String sessionId;
  final DateTime startTime;
  final double tariffPerHour;

  const ActiveSessionActive({
    required this.sessionId,
    required this.startTime,
    required this.tariffPerHour,
  });

  @override
  List<Object?> get props => [sessionId, startTime, tariffPerHour];
}

class ActiveSessionCompleted extends ActiveSessionState {}

class ActiveSessionError extends ActiveSessionState {
  final String message;

  const ActiveSessionError(this.message);

  @override
  List<Object?> get props => [message];
}
