import 'package:parqr/domain/entities/parking_lot_entity.dart';

class ParkingLotModel extends ParkingLotEntity {
  const ParkingLotModel({
    required super.id,
    required super.operatorId,
    required super.name,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.totalCapacity,
    required super.totalFloors,
    required super.pricePerHour,
    super.photoUrl,
    required super.createdAt,
  });

  factory ParkingLotModel.fromJson(Map<String, dynamic> json) {
    return ParkingLotModel(
      id: json['id'] as String,
      operatorId: json['operator_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      totalCapacity: json['total_capacity'] as int,
      totalFloors: json['total_floors'] as int,
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operator_id': operatorId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'total_capacity': totalCapacity,
      'total_floors': totalFloors,
      'price_per_hour': pricePerHour,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
