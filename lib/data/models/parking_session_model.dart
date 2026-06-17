import '../../domain/entities/parking_session_entity.dart';

class ParkingSessionModel extends ParkingSessionEntity {
  const ParkingSessionModel({
    required super.id,
    required super.userId,
    required super.vehicleId,
    required super.parkingLotId,
    super.parkingSlotId,
    required super.entryTime,
    super.exitTime,
    required super.status,
    required super.entryQrPayload,
    super.exitQrPayload,
    super.vehicleLatitude,
    super.vehicleLongitude,
    required super.createdAt,
  });

  factory ParkingSessionModel.fromJson(Map<String, dynamic> json) {
    return ParkingSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      vehicleId: json['vehicle_id'] as String,
      parkingLotId: json['parking_lot_id'] as String,
      parkingSlotId: json['parking_slot_id'] as String?,
      entryTime: DateTime.parse(json['entry_time'] as String),
      exitTime: json['exit_time'] != null
          ? DateTime.parse(json['exit_time'] as String)
          : null,
      status: json['status'] as String,
      entryQrPayload: json['entry_qr_payload'] as String,
      exitQrPayload: json['exit_qr_payload'] as String?,
      vehicleLatitude: json['vehicle_latitude'] != null
          ? (json['vehicle_latitude'] as num).toDouble()
          : null,
      vehicleLongitude: json['vehicle_longitude'] != null
          ? (json['vehicle_longitude'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_id': vehicleId,
      'parking_lot_id': parkingLotId,
      'parking_slot_id': parkingSlotId,
      'entry_time': entryTime.toIso8601String(),
      'exit_time': exitTime?.toIso8601String(),
      'status': status,
      'entry_qr_payload': entryQrPayload,
      'exit_qr_payload': exitQrPayload,
      'vehicle_latitude': vehicleLatitude,
      'vehicle_longitude': vehicleLongitude,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
