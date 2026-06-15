import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.profileCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.phone,
    this.address,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String? address;
  final String role;
  final bool profileCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isUser => role == 'user';
  bool get isOperator => role == 'operator';
  bool get isAdmin => role == 'admin';

  UserEntity copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? address,
    String? role,
    bool? profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role ?? this.role,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        address,
        role,
        profileCompleted,
        createdAt,
        updatedAt,
      ];
}
