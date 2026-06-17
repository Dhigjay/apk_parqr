import '../../domain/entities/parking_slot_entity.dart';

class ParkingSlotModel extends ParkingSlotEntity {
  const ParkingSlotModel({
    required super.id,
    required super.parkingLotId,
    required super.code,
    required super.floor,
    required super.isAvailable,
  });

  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSlotModel(
      id: json['id'] as String,
      parkingLotId: json['parking_lot_id'] as String,
      code: json['code'] as String,
      floor: json['floor'] as String,
      isAvailable: json['is_available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parking_lot_id': parkingLotId,
      'code': code,
      'floor': floor,
      'is_available': isAvailable,
    };
  }
}
