import 'package:equatable/equatable.dart';
import 'package:parqr/domain/entities/parking_history_entity.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<ParkingHistoryEntity> history;

  const HistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
