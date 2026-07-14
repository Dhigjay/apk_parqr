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
      // Kolom primary key di public.users adalah 'id', bukan 'auth_id'
      final response = await _supabaseClient
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = response?['role'] as String?;
      _cachedRole = (role != null && role.isNotEmpty) ? role : 'user';
      return _cachedRole!;
    } catch (e) {
      // Kalau row belum ada di public.users (race condition trigger)
      // atau ada error lain, fallback aman ke 'user'.
      _cachedRole = 'user';
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

  Future<void> register(
      String email, String password, String name, String phone) async {
    await _supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'phone': phone.trim(),
      },
    );

    // Fallback: jika trigger gagal/tidak ada, buat row public.users dari app
    final user = currentUser;
    if (user != null) {
      try {
        final existing = await _supabaseClient
            .from('users')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();

        if (existing == null) {
          await _supabaseClient.from('users').insert({
            'id': user.id,
            'email': email.trim(),
            'full_name': name.trim(),
            'phone': phone.trim(),
            'role': 'user',
            'profile_completed': false,
          });
        }
      } catch (e) {
        // Row mungkin sudah dibuat oleh trigger — abaikan error
      }
    }

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
