import 'package:equatable/equatable.dart';

class ParkingSlotEntity extends Equatable {
  final String id;
  final String lotId; // ✅ 'lot_id' sesuai schema
  final String code;
  final int floorNumber; // ✅ integer sesuai schema
  final String status; // 'available' | 'reserved' | 'occupied' | 'maintenance'

  const ParkingSlotEntity({
    required this.id,
    required this.lotId,
    required this.code,
    required this.floorNumber,
    required this.status,
  });

  bool get isAvailable => status == 'available';

  @override
  List<Object?> get props => [id, lotId, code, floorNumber, status];
}
