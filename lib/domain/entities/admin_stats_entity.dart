import 'package:equatable/equatable.dart';

class AdminStatsEntity extends Equatable {
  final int totalUsers;
  final int totalOperators;
  final int totalParkingLots;
  final int activeSessionsToday;
  final double totalRevenueToday;

  const AdminStatsEntity({
    required this.totalUsers,
    required this.totalOperators,
    required this.totalParkingLots,
    required this.activeSessionsToday,
    required this.totalRevenueToday,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalOperators,
        totalParkingLots,
        activeSessionsToday,
        totalRevenueToday,
      ];
}
