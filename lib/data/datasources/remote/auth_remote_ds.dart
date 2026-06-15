import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  User? get currentUser => _supabaseClient.auth.currentUser;

  bool get isLoggedIn => currentUser != null;

  String? get currentRole {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    final metadataRole = user.appMetadata['role'] ?? user.userMetadata?['role'];
    return metadataRole is String && metadataRole.isNotEmpty
        ? metadataRole
        : 'user';
  }

  Future<void> login(String email, String password) async {
    await _supabaseClient.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register(String email, String password, String name) async {
    await _supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'name': name.trim(),
        'role': 'user',
      },
    );
  }

  Future<void> logout() async {
    await _supabaseClient.auth.signOut();
  }
}
