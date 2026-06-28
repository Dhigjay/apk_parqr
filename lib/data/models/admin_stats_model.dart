import 'package:parqr/domain/entities/admin_stats_entity.dart';

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalUsers,
    required super.totalOperators,
    required super.totalParkingLots,
    required super.activeSessionsToday,
    required super.totalRevenueToday,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalUsers: json['total_users'] ?? 0,
      totalOperators: json['total_operators'] ?? 0,
      totalParkingLots: json['total_parking_lots'] ?? 0,
      activeSessionsToday: json['active_sessions_today'] ?? 0,
      totalRevenueToday: json['total_revenue_today']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_operators': totalOperators,
      'total_parking_lots': totalParkingLots,
      'active_sessions_today': activeSessionsToday,
      'total_revenue_today': totalRevenueToday,
    };
  }
}
