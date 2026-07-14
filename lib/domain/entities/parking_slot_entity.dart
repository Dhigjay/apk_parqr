import 'package:equatable/equatable.dart';

class ParkingSlotEntity extends Equatable {
  final String id;
  final String parkingLotId;
  final String code;
  final String floor;
  final bool isAvailable;

  const ParkingSlotEntity({
    required this.id,
    required this.parkingLotId,
    required this.code,
    required this.floor,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [
        id,
        parkingLotId,
        code,
        floor,
        isAvailable,
      ];
}
