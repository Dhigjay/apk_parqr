import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  const VehicleEntity({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.vehicleType,
    required this.plateNumber,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
  });

  final String id;
  final String userId;
  final String brand;
  final String model;
  final String vehicleType;
  final String plateNumber;
  final String? photoUrl;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName => '$brand $model'.trim();
  bool get isCar => vehicleType == 'mobil';
  bool get isMotorcycle => vehicleType == 'motor';

  VehicleEntity copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    String? vehicleType,
    String? plateNumber,
    String? photoUrl,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        brand,
        model,
        vehicleType,
        plateNumber,
        photoUrl,
        isPrimary,
        createdAt,
        updatedAt,
      ];
}
