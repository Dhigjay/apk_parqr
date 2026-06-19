import 'package:equatable/equatable.dart';

class ParkingLotEntity extends Equatable {
  final String id;
  final String operatorId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final int totalCapacity;
  final int totalFloors;
  final double pricePerHour;
  final String? photoUrl;
  final DateTime createdAt;

  const ParkingLotEntity({
    required this.id,
    required this.operatorId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.totalCapacity,
    required this.totalFloors,
    required this.pricePerHour,
    this.photoUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        operatorId,
        name,
        address,
        latitude,
        longitude,
        totalCapacity,
        totalFloors,
        pricePerHour,
        photoUrl,
        createdAt,
      ];
}
