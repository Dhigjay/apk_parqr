import 'package:equatable/equatable.dart';

/// Represents a scanned vehicle's parking session summary
class ActiveVehicle extends Equatable {
  final String sessionId;
  final String vehicleName;
  final String licensePlate;
  final DateTime checkInTime;
  final String floor;
  final double currentTariff;
  final bool awaitingCashVerification;

  const ActiveVehicle({
    required this.sessionId,
    required this.vehicleName,
    required this.licensePlate,
    required this.checkInTime,
    required this.floor,
    required this.currentTariff,
    this.awaitingCashVerification = false,
  });

  @override
  List<Object?> get props => [
        sessionId,
        vehicleName,
        licensePlate,
        checkInTime,
        floor,
        currentTariff,
        awaitingCashVerification,
      ];
}

/// Stats summary shown at the top of operator dashboard
class OperatorStats extends Equatable {
  final int vehiclesInToday;
  final int vehiclesActiveNow;
  final double revenueToday;

  const OperatorStats({
    required this.vehiclesInToday,
    required this.vehiclesActiveNow,
    required this.revenueToday,
  });

  @override
  List<Object?> get props => [vehiclesInToday, vehiclesActiveNow, revenueToday];
}

abstract class OperatorDashboardState extends Equatable {
  const OperatorDashboardState();

  @override
  List<Object?> get props => [];
}

class OperatorDashboardInitial extends OperatorDashboardState {}

class OperatorDashboardLoading extends OperatorDashboardState {}

class OperatorDashboardLoaded extends OperatorDashboardState {
  final OperatorStats stats;
  final List<ActiveVehicle> activeVehicles;

  const OperatorDashboardLoaded({
    required this.stats,
    required this.activeVehicles,
  });

  @override
  List<Object?> get props => [stats, activeVehicles];
}

class OperatorDashboardError extends OperatorDashboardState {
  final String message;

  const OperatorDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

class OperatorQrScanSuccess extends OperatorDashboardState {
  final String message;
  final ActiveVehicle vehicle;

  const OperatorQrScanSuccess({required this.message, required this.vehicle});

  @override
  List<Object?> get props => [message, vehicle];
}

class OperatorQrScanError extends OperatorDashboardState {
  final String message;

  const OperatorQrScanError(this.message);

  @override
  List<Object?> get props => [message];
}

class OperatorCashVerified extends OperatorDashboardState {}
