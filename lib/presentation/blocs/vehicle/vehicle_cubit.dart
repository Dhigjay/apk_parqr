import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/domain/repositories/i_vehicle_repository.dart';
import 'package:parqr/presentation/blocs/vehicle/vehicle_state.dart';

class VehicleCubit extends Cubit<VehicleState> {
  final IVehicleRepository _vehicleRepository;

  VehicleCubit({required IVehicleRepository vehicleRepository})
      : _vehicleRepository = vehicleRepository,
        super(VehicleInitial());

  Future<void> addVehicle({
    required String brand,
    required String model,
    required String vehicleType,
    required String plateNumber,
    String? photoPath,
  }) async {
    emit(VehicleLoading());
    try {
      // Add vehicle to database via repository
      await _vehicleRepository.addVehicle(
        brand: brand,
        model: model,
        vehicleType: vehicleType,
        plateNumber: plateNumber,
        isPrimary: true, // First vehicle is primary
        photoUrl: photoPath,
      );
      
      emit(VehicleAdded());
    } catch (e) {
      emit(VehicleError('Gagal menambahkan kendaraan: ${e.toString()}'));
    }
  }

  Future<void> fetchVehicles() async {
    emit(VehicleLoading());
    try {
      final vehicles = await _vehicleRepository.getMyVehicles();
      emit(VehicleLoaded(vehicles: vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
}
