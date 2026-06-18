import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../datasources/remote/user_remote_ds.dart';
import '../../core/error/exceptions.dart';

class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> getCurrentProfile() async {
    try {
      final model = await remoteDataSource.getCurrentProfile();
      return model;
    } on StateError catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserEntity> requireCurrentProfile() async {
    try {
      final model = await remoteDataSource.requireCurrentProfile();
      return model;
    } on StateError catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserEntity> upsertCurrentProfile({
    String? fullName,
    String? phone,
    String? address,
    bool? profileCompleted,
  }) async {
    try {
      final model = await remoteDataSource.upsertCurrentProfile(
        fullName: fullName,
        phone: phone,
        address: address,
        profileCompleted: profileCompleted,
      );
      return model;
    } on StateError catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserEntity> completeProfile({
    required String fullName,
    required String address,
    String? phone,
  }) async {
    try {
      final model = await remoteDataSource.completeProfile(
        fullName: fullName,
        address: address,
        phone: phone,
      );
      return model;
    } on StateError catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
