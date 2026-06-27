import 'package:parqr/domain/entities/user_entity.dart';

abstract class IUserRepository {
  Future<UserEntity?> getCurrentProfile();

  Future<UserEntity> requireCurrentProfile();

  Future<UserEntity> upsertCurrentProfile({
    String? fullName,
    String? phone,
    String? address,
    bool? profileCompleted,
  });

  Future<UserEntity> completeProfile({
    required String fullName,
    required String address,
    String? phone,
  });
}
