abstract class IAuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String name);
  Future<void> logout();
  bool get isLoggedIn;
}