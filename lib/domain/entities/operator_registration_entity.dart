import 'package:equatable/equatable.dart';

class OperatorRegistrationEntity extends Equatable {
  final String id;
  final String applicantUserId;
  final String businessName;
  final String address;
  final double? latitude;
  final double? longitude;
  final double? lotSizeM2;
  final int floors;
  final Map<String, dynamic> capacityPerFloor;
  final int totalCapacity;
  final double pricePerHour;
  final String? photoUrl;
  final String status;
  final String? rejectReason;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OperatorRegistrationEntity({
    required this.id,
    required this.applicantUserId,
    required this.businessName,
    required this.address,
    this.latitude,
    this.longitude,
    this.lotSizeM2,
    required this.floors,
    required this.capacityPerFloor,
    required this.totalCapacity,
    required this.pricePerHour,
    this.photoUrl,
    required this.status,
    this.rejectReason,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        applicantUserId,
        businessName,
        address,
        latitude,
        longitude,
        lotSizeM2,
        floors,
        capacityPerFloor,
        totalCapacity,
        pricePerHour,
        photoUrl,
        status,
        rejectReason,
        reviewedBy,
        reviewedAt,
        createdAt,
        updatedAt,
      ];
}
