import 'package:parqr/domain/entities/operator_registration_entity.dart';

class OperatorRegistrationModel extends OperatorRegistrationEntity {
  const OperatorRegistrationModel({
    required super.id,
    required super.applicantUserId,
    required super.businessName,
    required super.address,
    super.latitude,
    super.longitude,
    super.lotSizeM2,
    required super.floors,
    required super.capacityPerFloor,
    required super.totalCapacity,
    required super.pricePerHour,
    super.photoUrl,
    required super.status,
    super.rejectReason,
    super.reviewedBy,
    super.reviewedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OperatorRegistrationModel.fromJson(Map<String, dynamic> json) {
    return OperatorRegistrationModel(
      id: json['id'],
      applicantUserId: json['applicant_user_id'],
      businessName: json['business_name'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      lotSizeM2: json['lot_size_m2']?.toDouble(),
      floors: json['floors'] ?? 1,
      capacityPerFloor: json['capacity_per_floor'] ?? {},
      totalCapacity: json['total_capacity'],
      pricePerHour: json['price_per_hour']?.toDouble() ?? 0.0,
      photoUrl: json['photo_url'],
      status: json['status'] ?? 'pending',
      rejectReason: json['reject_reason'],
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']).toLocal() : null,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicant_user_id': applicantUserId,
      'business_name': businessName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'lot_size_m2': lotSizeM2,
      'floors': floors,
      'capacity_per_floor': capacityPerFloor,
      'total_capacity': totalCapacity,
      'price_per_hour': pricePerHour,
      'photo_url': photoUrl,
      'status': status,
    };
  }
}
