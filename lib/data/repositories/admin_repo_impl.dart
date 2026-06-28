import 'package:parqr/core/error/exceptions.dart';
import 'package:parqr/domain/entities/admin_stats_entity.dart';
import 'package:parqr/domain/entities/operator_registration_entity.dart';
import 'package:parqr/domain/repositories/i_admin_repository.dart';
import 'package:parqr/data/datasources/remote/admin_remote_ds.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OperatorRegistrationEntity>> getPendingRegistrations() async {
    try {
      final registrations = await remoteDataSource.getPendingRegistrations();
      return registrations;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<OperatorRegistrationEntity> getRegistrationDetail(String id) async {
    try {
      final registration = await remoteDataSource.getRegistrationDetail(id);
      return registration;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> approveOperator(String id) async {
    try {
      await remoteDataSource.approveOperator(id);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> rejectOperator(String id, String reason) async {
    try {
      await remoteDataSource.rejectOperator(id, reason);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<AdminStatsEntity> getGlobalStats() async {
    try {
      final stats = await remoteDataSource.getGlobalStats();
      return stats;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }
}
