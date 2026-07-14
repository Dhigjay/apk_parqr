import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/data/models/user_model.dart';

class UserRemoteDataSource {
  UserRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  // Ambil auth user yang sedang login.
  User get _currentAuthUser {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('User belum terautentikasi.');
    }
    return user;
  }

  /// Ambil profil user dari public.users berdasarkan auth_id
  /// (BUKAN .eq('id', user.id) — karena public.users.id ≠ auth.users.id)
  Future<UserModel?> getCurrentProfile() async {
    final user = _currentAuthUser;
    final data = await _supabaseClient
        .from('users')
        .select()
        .eq('auth_id', user.id) // ✅ pakai auth_id, bukan id
        .maybeSingle();

    if (data == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<UserModel> requireCurrentProfile() async {
    final profile = await getCurrentProfile();
    if (profile == null) {
      throw StateError('Profil user belum dibuat.');
    }
    return profile;
  }

  /// Update profil user yang sudah ada di public.users.
  ///
  /// Tidak perlu INSERT di sini — trigger on_auth_user_created sudah otomatis
  /// membuat baris di public.users setiap kali user baru register.
  /// Kalau row belum ada (edge case trigger gagal), akan throw error yang jelas.
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
      if (fullName != null) 'name': fullName.trim(),
      if (phone != null) 'phone': _blankToNull(phone),
      if (address != null) 'address': _blankToNull(address),
      if (profileCompleted != null) 'profile_completed': profileCompleted,
    };

    // Pastikan row sudah ada (dibuat oleh trigger saat register)
    final existing = await _supabaseClient
        .from('users')
        .select('id')
        .eq('auth_id', user.id) // ✅ filter pakai auth_id
        .maybeSingle();

    if (existing == null) {
      // Trigger gagal jalan saat register — buat baris manual sebagai fallback
      await _supabaseClient.from('users').insert({
        'auth_id': user.id, // ✅ auth_id, bukan id
        'email': user.email ?? '',
        'name': fullName?.trim() ?? 'User', // ✅ nama kolom: 'name'
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        if (address != null && address.trim().isNotEmpty)
          'address': address.trim(),
        'is_profile_complete':
            profileCompleted ?? false, // ✅ nama kolom: 'is_profile_complete'
      });
    } else {
      // Normal case: row sudah ada, lakukan UPDATE
      final updatePayload = <String, dynamic>{};

      if (fullName != null && fullName.trim().isNotEmpty) {
        updatePayload['name'] = fullName.trim(); // ✅ 'name', bukan 'full_name'
      }
      if (phone != null && phone.trim().isNotEmpty) {
        updatePayload['phone'] = phone.trim();
      }
      if (address != null && address.trim().isNotEmpty) {
        updatePayload['address'] = address.trim();
      }
      // Set is_profile_complete = true secara otomatis kalau nama & alamat sudah diisi,
      // tanpa perlu menunggu parameter profileCompleted dikirim dari caller.
      // Ini menyelesaikan kasus updateProfile() di ProfileCubit yang tidak mengirim
      // profileCompleted sama sekali.
      if (profileCompleted != null) {
        updatePayload['is_profile_complete'] = profileCompleted;
      } else if (fullName != null &&
          fullName.trim().isNotEmpty &&
          address != null &&
          address.trim().isNotEmpty) {
        updatePayload['is_profile_complete'] = true;
      }

      print('🔍 Updating user profile: $updatePayload');

      await _supabaseClient
          .from('users')
          .update(updatePayload)
          .eq('auth_id', user.id); // ✅ filter pakai auth_id
    }

    // Ambil data terbaru setelah insert/update
    final data = await _supabaseClient
        .from('users')
        .select()
        .eq('auth_id', user.id)
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
