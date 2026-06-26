import 'package:parqr/domain/entities/parking_lot_entity.dart';
import 'package:parqr/domain/entities/parking_slot_entity.dart';

abstract class IParkingLotRepository {
  Future<List<ParkingLotEntity>> searchParkingLots(String query);
  Future<ParkingLotEntity> getParkingLotDetail(String id);
  Future<List<ParkingSlotEntity>> getAvailableSlots(String parkingLotId);
  
  // Operator CRUD methods
  Future<void> createParkingLot(ParkingLotEntity lot);
  Future<void> updateParkingLot(ParkingLotEntity lot);
  Future<void> addParkingSlot(ParkingSlotEntity slot);
  Future<void> updateParkingSlot(ParkingSlotEntity slot);
}
