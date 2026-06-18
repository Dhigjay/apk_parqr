import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/operator_registration_entity.dart';
import '../entities/admin_stats_entity.dart';

abstract class IAdminRepository {
  Future<Either<Failure, List<OperatorRegistrationEntity>>> getPendingRegistrations();
  Future<Either<Failure, OperatorRegistrationEntity>> getRegistrationDetail(String id);
  Future<Either<Failure, void>> approveOperator(String id);
  Future<Either<Failure, void>> rejectOperator(String id, String reason);
  Future<Either<Failure, AdminStatsEntity>> getGlobalStats();
}
