import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  User get _currentAuthUser {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('User belum terautentikasi.');
    }

    return user;
  }

  Future<UserModel?> getCurrentProfile() async {
    final user = _currentAuthUser;
    final data = await _supabaseClient
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<UserModel> requireCurrentProfile() async {
    final profile = await getCurrentProfile();
    if (profile == null) {
      throw StateError('Profil user belum dibuat.');
    }

    return profile;
  }

  Future<UserModel> upsertCurrentProfile({
    String? fullName,
    String? phone,
    String? address,
    bool? profileCompleted,
  }) async {
    final user = _currentAuthUser;
    final payload = <String, dynamic>{
      'id': user.id,
      'email': user.email ?? '',
      'role': 'user',
      if (fullName != null) 'full_name': fullName.trim(),
      if (phone != null) 'phone': _blankToNull(phone),
      if (address != null) 'address': _blankToNull(address),
      if (profileCompleted != null) 'profile_completed': profileCompleted,
    };

    final data = await _supabaseClient
        .from('users')
        .upsert(payload, onConflict: 'id')
        .select()
        .single();

    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<UserModel> completeProfile({
    required String fullName,
    required String address,
    String? phone,
  }) {
    return upsertCurrentProfile(
      fullName: fullName,
      phone: phone,
      address: address,
      profileCompleted: true,
    );
  }
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
