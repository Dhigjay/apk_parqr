abstract class IAuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String name, String phone);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  bool get isLoggedIn;
  String? get currentRole;
}
