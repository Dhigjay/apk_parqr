import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.userId,
    required super.brand,
    required super.model,
    required super.vehicleType,
    required super.plateNumber,
    required super.isPrimary,
    required super.createdAt,
    required super.updatedAt,
    super.photoUrl,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? 'mobil',
      plateNumber: json['plate_number'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      id: entity.id,
      userId: entity.userId,
      brand: entity.brand,
      model: entity.model,
      vehicleType: entity.vehicleType,
      plateNumber: entity.plateNumber,
      photoUrl: entity.photoUrl,
      isPrimary: entity.isPrimary,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'photo_url': photoUrl,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpsertJson() {
    return {
      'id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'vehicle_type': vehicleType,
      'plate_number': plateNumber,
      'photo_url': photoUrl,
      'is_primary': isPrimary,
    };
  }
}

DateTime _parseDate(Object? value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String && value.isNotEmpty) {
    return DateTime.parse(value);
  }

  return DateTime.fromMillisecondsSinceEpoch(0);
}
