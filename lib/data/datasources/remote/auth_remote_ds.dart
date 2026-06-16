import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  User? get currentUser => _supabaseClient.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await _supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'role': 'user',
      },
    );

    final user = response.user;
    if (user == null) {
      return;
    }

    await _supabaseClient.from('users').upsert(
      {
        'id': user.id,
        'email': email.trim(),
        'full_name': name.trim(),
        'role': 'user',
        'profile_completed': false,
      },
      onConflict: 'id',
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _supabaseClient.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }
}
