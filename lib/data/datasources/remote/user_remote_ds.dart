import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:parqr/data/models/user_model.dart';

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
    
    // Check if user already exists first
    final existing = await _supabaseClient
        .from('users')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    
    if (existing != null) {
      // User exists - do UPDATE only (don't send id or email)
      final updatePayload = <String, dynamic>{};
      
      if (fullName != null && fullName.trim().isNotEmpty) {
        updatePayload['name'] = fullName.trim();
        updatePayload['full_name'] = fullName.trim();
      }
      
      if (phone != null && phone.trim().isNotEmpty) {
        updatePayload['phone_number'] = phone.trim();
        updatePayload['phone'] = phone.trim();
      }
      
      if (address != null && address.trim().isNotEmpty) {
        updatePayload['address'] = address.trim();
      }
      
      if (profileCompleted != null) {
        updatePayload['profile_completed'] = profileCompleted;
      }

      print('🔍 Updating existing user: $updatePayload');

      final data = await _supabaseClient
          .from('users')
          .update(updatePayload)
          .eq('id', user.id)
          .select()
          .single();

      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } else {
      // User doesn't exist - do INSERT
      final insertPayload = <String, dynamic>{
        'id': user.id,
        'email': user.email ?? '',
      };
      
      if (fullName != null && fullName.trim().isNotEmpty) {
        insertPayload['name'] = fullName.trim();
        insertPayload['full_name'] = fullName.trim();
      }
      
      if (phone != null && phone.trim().isNotEmpty) {
        insertPayload['phone_number'] = phone.trim();
        insertPayload['phone'] = phone.trim();
      }
      
      if (address != null && address.trim().isNotEmpty) {
        insertPayload['address'] = address.trim();
      }
      
      if (profileCompleted != null) {
        insertPayload['profile_completed'] = profileCompleted;
      }

      print('🔍 Inserting new user: $insertPayload');

      final data = await _supabaseClient
          .from('users')
          .insert(insertPayload)
          .select()
          .single();

      return UserModel.fromJson(Map<String, dynamic>.from(data));
    }
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
