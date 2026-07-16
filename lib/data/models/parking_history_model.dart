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
    var lotRaw = json['parking_lots'];
    Map<String, dynamic> lot = {};
    if (lotRaw is List && lotRaw.isNotEmpty) lot = lotRaw.first as Map<String, dynamic>;
    else if (lotRaw is Map<String, dynamic>) lot = lotRaw;

    var vehicleRaw = json['vehicles'];
    Map<String, dynamic> vehicle = {};
    if (vehicleRaw is List && vehicleRaw.isNotEmpty) vehicle = vehicleRaw.first as Map<String, dynamic>;
    else if (vehicleRaw is Map<String, dynamic>) vehicle = vehicleRaw;
    
    // For payments, it might be a list of payments if multiple exist, but usually it's one.
    // We'll safely parse the amount from the first payment or direct object if one-to-one
    final payments = json['payments'];
    double? fare;
    if (payments is List && payments.isNotEmpty) {
      fare = (payments.first['amount'] as num?)?.toDouble();
    } else if (payments is Map<String, dynamic>) {
      fare = (payments['amount'] as num?)?.toDouble();
    }

    final entryStr = json['entry_time'] ?? json['entered_at'] ?? json['created_at'];
    final entry = entryStr != null ? DateTime.parse(entryStr as String) : DateTime.now();
    final exitStr = json['exit_time'] ?? json['exited_at'];
    final exit = exitStr != null ? DateTime.parse(exitStr as String) : null;
    final statusStr = json['status'] as String? ?? 'active';

    return ParkingHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      parkingLotName: lot['name'] as String? ?? 'Unknown Parking Lot',
      parkingLotAddress: lot['address'] as String? ?? '-',
      entryTime: entry,
      exitTime: exit,
      status: statusStr,
      vehicleName: '${vehicle['brand'] ?? ''} ${vehicle['model'] ?? ''}'.trim(),
      vehicleLicensePlate: vehicle['plate_number'] as String? ?? '-',
      totalFare: fare,
      isOngoing: statusStr == 'active' || statusStr == 'booked',
    );
  }
}
