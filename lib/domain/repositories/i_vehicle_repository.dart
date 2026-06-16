import 'dart:typed_data';

import '../entities/vehicle_entity.dart';

abstract class IVehicleRepository {
  Future<List<VehicleEntity>> getMyVehicles();

  Future<VehicleEntity> getVehicleById(String id);

  Future<VehicleEntity> addVehicle({
    required String brand,
    required String model,
    required String vehicleType,
    required String plateNumber,
    String? photoUrl,
    bool isPrimary,
  });

  Future<VehicleEntity> updateVehicle({
    required String id,
    String? brand,
    String? model,
    String? vehicleType,
    String? plateNumber,
    String? photoUrl,
    bool? isPrimary,
  });

  Future<String> uploadVehiclePhoto({
    required String vehicleId,
    required Uint8List bytes,
    required String fileExtension,
    String? contentType,
  });

  Future<VehicleEntity> setPrimaryVehicle(String id);

  Future<void> deleteVehicle(String id);
}
