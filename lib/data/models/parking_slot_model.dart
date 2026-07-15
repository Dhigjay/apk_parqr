import 'package:parqr/domain/entities/parking_slot_entity.dart';

class ParkingSlotModel extends ParkingSlotEntity {
  const ParkingSlotModel({
    required super.id,
    required super.lotId,
    required super.code,
    required super.floorNumber,
    required super.status,
  });

  factory ParkingSlotModel.fromJson(Map<String, dynamic> json) {
    return ParkingSlotModel(
      id: json['id'] as String,
      lotId: (json['lot_id'] ?? json['parking_lot_id']) as String,
      code: json['code'] as String,
      floorNumber: json['floor_number'] as int? ??
          int.tryParse(json['floor']?.toString() ?? '') ??
          1,
      status: json['status'] as String? ?? 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parking_lot_id': lotId,
      'code': code,
      'floor': floorNumber.toString(),
      'status': status,
    };
  }
}
