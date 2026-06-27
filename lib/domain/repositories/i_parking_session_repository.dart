import 'package:parqr/domain/entities/parking_session_entity.dart';

abstract class IParkingSessionRepository {
  Future<ParkingSessionEntity> bookParkingSlot({
    required String userId,
    required String vehicleId,
    required String parkingLotId,
    String? parkingSlotId,
  });

  String generateEntryQrPayload(String sessionId);

  bool validateQrExpiration(String payload);
}
