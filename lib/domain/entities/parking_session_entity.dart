import 'package:equatable/equatable.dart';

class ParkingSessionEntity extends Equatable {
  final String id;
  final String userId;
  final String vehicleId;
  final String parkingLotId;
  final String? parkingSlotId;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String status; // e.g. "active", "completed", "booked"
  final String entryQrPayload;
  final String? exitQrPayload;
  final double? vehicleLatitude;
  final double? vehicleLongitude;
  final DateTime createdAt;

  const ParkingSessionEntity({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.parkingLotId,
    this.parkingSlotId,
    required this.entryTime,
    this.exitTime,
    required this.status,
    required this.entryQrPayload,
    this.exitQrPayload,
    this.vehicleLatitude,
    this.vehicleLongitude,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        vehicleId,
        parkingLotId,
        parkingSlotId,
        entryTime,
        exitTime,
        status,
        entryQrPayload,
        exitQrPayload,
        vehicleLatitude,
        vehicleLongitude,
        createdAt,
      ];
}
