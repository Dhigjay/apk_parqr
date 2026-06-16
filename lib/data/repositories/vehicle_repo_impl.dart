import 'dart:typed_data';

import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/i_vehicle_repository.dart';
import '../datasources/remote/vehicle_remote_ds.dart';
import '../../core/error/exceptions.dart';

class VehicleRepositoryImpl implements IVehicleRepository {
  final VehicleRemoteDataSource remoteDataSource;

  VehicleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<VehicleEntity>> getMyVehicles() async {
    try {
      final models = await remoteDataSource.getMyVehicles();
      return models;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleEntity> getVehicleById(String id) async {
    try {
      final model = await remoteDataSource.getVehicleById(id);
      return model;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleEntity> addVehicle({
    required String brand,
    required String model,
    required String vehicleType,
    required String plateNumber,
    String? photoUrl,
    bool isPrimary = false,
  }) async {
    try {
      final result = await remoteDataSource.addVehicle(
        brand: brand,
        model: model,
        vehicleType: vehicleType,
        plateNumber: plateNumber,
        photoUrl: photoUrl,
        isPrimary: isPrimary,
      );
      return result;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleEntity> updateVehicle({
    required String id,
    String? brand,
    String? model,
    String? vehicleType,
    String? plateNumber,
    String? photoUrl,
    bool? isPrimary,
  }) async {
    try {
      final result = await remoteDataSource.updateVehicle(
        id: id,
        brand: brand,
        model: model,
        vehicleType: vehicleType,
        plateNumber: plateNumber,
        photoUrl: photoUrl,
        isPrimary: isPrimary,
      );
      return result;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadVehiclePhoto({
    required String vehicleId,
    required Uint8List bytes,
    required String fileExtension,
    String? contentType,
  }) async {
    try {
      final url = await remoteDataSource.uploadVehiclePhoto(
        vehicleId: vehicleId,
        bytes: bytes,
        fileExtension: fileExtension,
        contentType: contentType,
      );
      return url;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VehicleEntity> setPrimaryVehicle(String id) async {
    try {
      final result = await remoteDataSource.setPrimaryVehicle(id);
      return result;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteVehicle(String id) async {
    try {
      await remoteDataSource.deleteVehicle(id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
