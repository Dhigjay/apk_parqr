abstract class IAuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String name, String phone);
  Future<void> forgotPassword(String email);
  Future<void> logout();
  bool get isLoggedIn;
  String? get currentRole;

  /// Ambil ulang role terbaru dari database (public.users).
  /// Dipanggil saat app dibuka kembali dan ada sesi login aktif,
  /// karena currentRole adalah cache yang perlu di-refresh dulu.
  Future<String> refreshCurrentRole();
}