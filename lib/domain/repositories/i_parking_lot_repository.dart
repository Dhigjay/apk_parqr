import '../entities/parking_lot_entity.dart';
import '../entities/parking_slot_entity.dart';

abstract class IParkingLotRepository {
  Future<List<ParkingLotEntity>> searchParkingLots(String query);
  Future<ParkingLotEntity> getParkingLotDetail(String id);
  Future<List<ParkingSlotEntity>> getAvailableSlots(String parkingLotId);
}
