import 'package:parqr/domain/entities/parking_history_entity.dart';

class ParkingHistoryModel extends ParkingHistoryEntity {
  const ParkingHistoryModel({
    required super.id,
    required super.userId,
    required super.parkingLotName,
    required super.parkingLotAddress,
    required super.entryTime,
    super.exitTime,
    required super.status,
    required super.vehicleName,
    required super.vehicleLicensePlate,
    super.totalFare,
    required super.isOngoing,
  });

  factory ParkingHistoryModel.fromJson(Map<String, dynamic> json) {
    // Supabase joined tables are returned as nested maps
    final lot = json['parking_lots'] as Map<String, dynamic>? ?? {};
    final vehicle = json['vehicles'] as Map<String, dynamic>? ?? {};
    
    // For payments, it might be a list of payments if multiple exist, but usually it's one.
    // We'll safely parse the amount from the first payment or direct object if one-to-one
    final payments = json['payments'];
    double? fare;
    if (payments is List && payments.isNotEmpty) {
      fare = (payments.first['amount'] as num?)?.toDouble();
    } else if (payments is Map<String, dynamic>) {
      fare = (payments['amount'] as num?)?.toDouble();
    }

    final entry = DateTime.parse(json['entry_time'] as String);
    final exit = json['exit_time'] != null ? DateTime.parse(json['exit_time'] as String) : null;
    final statusStr = json['status'] as String? ?? 'active';

    return ParkingHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      parkingLotName: lot['name'] as String? ?? 'Unknown Parking Lot',
      parkingLotAddress: lot['address'] as String? ?? '-',
      entryTime: entry,
      exitTime: exit,
      status: statusStr,
      vehicleName: vehicle['name'] as String? ?? '-',
      vehicleLicensePlate: vehicle['license_plate'] as String? ?? '-',
      totalFare: fare,
      isOngoing: statusStr == 'active' || statusStr == 'booked',
    );
  }
}
