import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  VehicleCubit() : super(VehicleInitial());

  Future<void> addVehicle({
    required String brand,
    required String model,
    required String type,
    required String licensePlate,
    String? photoPath,
  }) async {
    emit(VehicleLoading());
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      emit(VehicleAddedSuccess());
      // Re-fetch vehicles
      emit(const VehicleLoaded(vehicles: []));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
}
