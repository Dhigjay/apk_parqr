import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/remote/auth_remote_ds.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  bool get isLoggedIn => _remoteDataSource.isLoggedIn;

  @override
  Future<void> login(String email, String password) {
    return _remoteDataSource.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> register(String email, String password, String name) {
    return _remoteDataSource.register(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _remoteDataSource.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }
}
