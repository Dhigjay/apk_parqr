import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/admin_stats_entity.dart';
import '../../../domain/entities/operator_registration_entity.dart';
import '../../../domain/repositories/i_admin_repository.dart';
import '../datasources/remote/admin_remote_ds.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OperatorRegistrationEntity>>> getPendingRegistrations() async {
    try {
      final registrations = await remoteDataSource.getPendingRegistrations();
      return Right(registrations);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, OperatorRegistrationEntity>> getRegistrationDetail(String id) async {
    try {
      final registration = await remoteDataSource.getRegistrationDetail(id);
      return Right(registration);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> approveOperator(String id) async {
    try {
      await remoteDataSource.approveOperator(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectOperator(String id, String reason) async {
    try {
      await remoteDataSource.rejectOperator(id, reason);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, AdminStatsEntity>> getGlobalStats() async {
    try {
      final stats = await remoteDataSource.getGlobalStats();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error occurred: $e'));
    }
  }
}
