import 'package:equatable/equatable.dart';

class ParkingHistoryEntity extends Equatable {
  final String id;
  final String userId;
  final String parkingLotName;
  final String parkingLotAddress;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String status;
  final String vehicleName;
  final String vehicleLicensePlate;
  final double? totalFare;
  final bool isOngoing;

  const ParkingHistoryEntity({
    required this.id,
    required this.userId,
    required this.parkingLotName,
    required this.parkingLotAddress,
    required this.entryTime,
    this.exitTime,
    required this.status,
    required this.vehicleName,
    required this.vehicleLicensePlate,
    this.totalFare,
    required this.isOngoing,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        parkingLotName,
        parkingLotAddress,
        entryTime,
        exitTime,
        status,
        vehicleName,
        vehicleLicensePlate,
        totalFare,
        isOngoing,
      ];
}
