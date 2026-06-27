import 'package:parqr/domain/repositories/i_auth_repository.dart';
import 'package:parqr/data/datasources/remote/auth_remote_ds.dart';

class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final AuthRemoteDataSource _remoteDataSource;

  @override
  bool get isLoggedIn => _remoteDataSource.isLoggedIn;

  @override
  String? get currentRole => _remoteDataSource.currentRole;

  @override
  Future<String> refreshCurrentRole() => _remoteDataSource.refreshCurrentRole();

  @override
  Future<void> login(String email, String password) {
    return _remoteDataSource.login(email, password);
  }

  @override
  Future<void> register(String email, String password, String name, String phone) {
    return _remoteDataSource.register(email, password, name, phone);
  }

  @override
  Future<void> forgotPassword(String email) {
    return _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> logout() {
    return _remoteDataSource.logout();
  }
}