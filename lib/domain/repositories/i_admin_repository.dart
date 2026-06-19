import '../entities/operator_registration_entity.dart';
import '../entities/admin_stats_entity.dart';

abstract class IAdminRepository {
  Future<List<OperatorRegistrationEntity>> getPendingRegistrations();
  Future<OperatorRegistrationEntity> getRegistrationDetail(String id);
  Future<void> approveOperator(String id);
  Future<void> rejectOperator(String id, String reason);
  Future<AdminStatsEntity> getGlobalStats();
}
