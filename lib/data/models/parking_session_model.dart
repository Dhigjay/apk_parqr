import 'package:parqr/domain/entities/parking_session_entity.dart';

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
      parkingLotId: (json['parking_lot_id'] ?? json['lot_id'] ?? '') as String,
      parkingSlotId: (json['parking_slot_id'] ?? json['slot_id']) as String?,
      entryTime: DateTime.parse((json['entry_time'] ?? json['entered_at'] ?? json['created_at']) as String),
      exitTime: (json['exit_time'] ?? json['exited_at']) != null
          ? DateTime.parse((json['exit_time'] ?? json['exited_at']) as String)
          : null,
      status: json['status'] as String,
      entryQrPayload: (json['entry_qr_payload'] ?? json['entry_qr_token'] ?? json['entry_qr'] ?? '') as String,
      exitQrPayload: (json['exit_qr_payload'] ?? json['exit_qr_token'] ?? json['exit_qr']) as String?,
      vehicleLatitude: (json['vehicle_latitude'] ?? json['saved_latitude']) != null
          ? ((json['vehicle_latitude'] ?? json['saved_latitude']) as num).toDouble()
          : null,
      vehicleLongitude: (json['vehicle_longitude'] ?? json['saved_longitude']) != null
          ? ((json['vehicle_longitude'] ?? json['saved_longitude']) as num).toDouble()
          : null,
      createdAt: DateTime.parse((json['created_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_id': vehicleId,
      'lot_id': parkingLotId,
      if (parkingSlotId != null) 'slot_id': parkingSlotId,
      'entered_at': entryTime.toIso8601String(),
      if (exitTime != null) 'exited_at': exitTime?.toIso8601String(),
      'status': status,
      'entry_qr_token': entryQrPayload,
      if (exitQrPayload != null) 'exit_qr_token': exitQrPayload,
      if (vehicleLatitude != null) 'saved_latitude': vehicleLatitude,
      if (vehicleLongitude != null) 'saved_longitude': vehicleLongitude,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
