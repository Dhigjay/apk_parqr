import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  // Cache role di memory supaya getter sync (currentRole) tetap bisa dipakai
  // tanpa perlu await di tempat lain. Diisi ulang setiap login/cek status.
  String? _cachedRole;

  User? get currentUser => _supabaseClient.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  /// Getter sync — dipakai oleh AuthBloc setelah _fetchAndCacheRole() dipanggil.
  String? get currentRole => _cachedRole;

  /// Ambil role dari tabel public.users (BUKAN dari auth metadata)
  /// dan simpan ke cache. Harus dipanggil setiap kali:
  /// - setelah login berhasil
  /// - saat app dibuka & user sudah ada sesi sebelumnya (cek status)
  Future<String> _fetchAndCacheRole() async {
    final user = currentUser;
    if (user == null) {
      _cachedRole = null;
      return 'visitor';
    }

    try {
      final response = await _supabaseClient
          .from('users')
          .select('role')
          .eq('auth_id', user.id)
          .single();

      final role = response['role'] as String?;
      _cachedRole = (role != null && role.isNotEmpty) ? role : 'visitor';
      return _cachedRole!;
    } catch (e) {
      // Kalau row belum ada di public.users (race condition trigger)
      // atau ada error lain, fallback aman ke visitor.
      _cachedRole = 'visitor';
      return _cachedRole!;
    }
  }

  Future<void> login(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    // Penting: ambil role dari DB segera setelah login sukses
    await _fetchAndCacheRole();
  }

  /// Dipanggil dari AuthBloc saat AuthCheckStatusRequested (splash screen)
  /// untuk memastikan cache role terisi meski app baru dibuka ulang.
  Future<String> refreshCurrentRole() => _fetchAndCacheRole();

  Future<void> register(String email, String password, String name, String phone) async {
    await _supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'phone': phone.trim(),
      },
    );
    // Trigger on_auth_user_created akan otomatis membuat row di public.users
    // dengan role default 'visitor'.
    await _fetchAndCacheRole();
  }

  Future<void> forgotPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
    _cachedRole = null;
  }
}