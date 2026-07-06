import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parqr/domain/repositories/i_parking_lot_repository.dart';
import 'package:parqr/presentation/blocs/parking_lot/parking_lot_event.dart';
import 'package:parqr/presentation/blocs/parking_lot/parking_lot_state.dart';

class ParkingLotBloc extends Bloc<ParkingLotEvent, ParkingLotState> {
  final IParkingLotRepository _parkingLotRepository;

  ParkingLotBloc({required IParkingLotRepository parkingLotRepository})
      : _parkingLotRepository = parkingLotRepository,
        super(ParkingLotInitial()) {
    on<SearchParkingLotsRequested>(_onSearchParkingLotsRequested);
  }

  Future<void> _onSearchParkingLotsRequested(
    SearchParkingLotsRequested event,
    Emitter<ParkingLotState> emit,
  ) async {
    emit(ParkingLotLoading());
    try {
      final parkingLots = await _parkingLotRepository.searchParkingLots(event.query);
      
      Map<String, String> distances = {};
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
            for (var lot in parkingLots) {
              double distanceInMeters = Geolocator.distanceBetween(
                position.latitude, 
                position.longitude, 
                lot.latitude, 
                lot.longitude
              );
              
              if (distanceInMeters < 1000) {
                distances[lot.id] = '${distanceInMeters.toStringAsFixed(0)} m';
              } else {
                distances[lot.id] = '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
              }
            }
          }
        }
      } catch (e) {
        // Ignore location errors and just don't populate distances
      }

      emit(ParkingLotLoaded(parkingLots, distances: distances));
    } catch (e) {
      emit(ParkingLotError(e.toString()));
    }
  }
}
