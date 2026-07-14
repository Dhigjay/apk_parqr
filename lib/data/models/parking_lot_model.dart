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
      id: json['id'] as String? ?? '',
      operatorId: (json['owner_id'] ?? json['operator_id']) as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      totalCapacity: (json['total_capacity'] ?? json['capacity']) as int? ?? 0,
      totalFloors: json['floors'] as int? ?? 1,
      pricePerHour:
          ((json['price_per_hour'] ?? json['hourly_rate']) as num?)
                  ?.toDouble() ??
              0.0,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': operatorId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'total_capacity': totalCapacity,
      'floors': totalFloors,
      'hourly_rate': pricePerHour,
      'status': 'active',
      'photo_url': photoUrl,
    };
  }
}
