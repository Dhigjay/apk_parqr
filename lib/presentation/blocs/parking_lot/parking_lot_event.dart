import 'package:equatable/equatable.dart';

abstract class ParkingLotEvent extends Equatable {
  const ParkingLotEvent();

  @override
  List<Object> get props => [];
}

class SearchParkingLotsRequested extends ParkingLotEvent {
  final String query;

  const SearchParkingLotsRequested(this.query);

  @override
  List<Object> get props => [query];
}
