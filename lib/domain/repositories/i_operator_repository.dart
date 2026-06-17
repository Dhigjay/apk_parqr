import '../entities/operator_registration_entity.dart';
import '../entities/parking_session_entity.dart';

abstract class IOperatorRepository {
  Future<void> registerOperator(OperatorRegistrationEntity registration);
  Future<OperatorRegistrationEntity?> getOperatorRegistrationStatus(String userId);
  Future<Map<String, dynamic>> getDashboardStats(String operatorId);
  Future<ParkingSessionEntity> scanCheckIn(String entryQrToken, String operatorId);
  Future<ParkingSessionEntity> scanCheckOut(String exitQrToken, String operatorId);
  Stream<List<ParkingSessionEntity>> listenToActiveSessions(String lotId);
}
