import 'package:parqr/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.profileCompleted,
    required super.createdAt,
    required super.updatedAt,
    super.fullName,
    super.phone,
    super.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String? ?? 'user',
      profileCompleted: json['profile_completed'] as bool? ?? false,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      fullName: entity.fullName,
      phone: entity.phone,
      address: entity.address,
      role: entity.role,
      profileCompleted: entity.profileCompleted,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'role': role,
      'profile_completed': profileCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpsertJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'role': role,
      'profile_completed': profileCompleted,
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
