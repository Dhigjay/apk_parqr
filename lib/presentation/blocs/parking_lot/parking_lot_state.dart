import 'package:equatable/equatable.dart';
import 'package:parqr/domain/entities/parking_lot_entity.dart';

abstract class ParkingLotState extends Equatable {
  const ParkingLotState();

  @override
  List<Object> get props => [];
}

class ParkingLotInitial extends ParkingLotState {}

class ParkingLotLoading extends ParkingLotState {}

class ParkingLotLoaded extends ParkingLotState {
  final List<ParkingLotEntity> parkingLots;
  final Map<String, String> distances; // map of parking lot id to formatted distance string

  const ParkingLotLoaded(this.parkingLots, {this.distances = const {}});

  @override
  List<Object> get props => [parkingLots, distances];
}

class ParkingLotError extends ParkingLotState {
  final String message;

  const ParkingLotError(this.message);

  @override
  List<Object> get props => [message];
}
