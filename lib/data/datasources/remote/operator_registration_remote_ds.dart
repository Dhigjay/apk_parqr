import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/core/error/exceptions.dart';

class OperatorRegistrationRemoteDataSource {
  OperatorRegistrationRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  /// Submit pengajuan pendaftaran operator baru.
  /// [capacityPerFloor] contoh: {"1": 20, "2": 30}
  Future<void> submitRegistration({
    required String businessName,
    required String address,
    double? latitude,
    double? longitude,
    double? lotSizeM2,
    required int floors,
    required Map<String, int> capacityPerFloor,
    required int totalCapacity,
    required double pricePerHour,
    String? photoUrl,
  }) async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      throw ServerException(message: 'User belum login.');
    }

    try {
      // applicant_user_id mengacu ke public.users.id, BUKAN auth.users.id langsung,
      // jadi kita cari dulu id internal dari auth_id.
      final userRow = await _supabaseClient
          .from('users')
          .select('id')
          .eq('auth_id', currentUser.id)
          .single();

      final applicantUserId = userRow['id'] as String;

      await _supabaseClient.from('operator_registrations').insert({
        'applicant_user_id': applicantUserId,
        'business_name': businessName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'lot_size_m2': lotSizeM2,
        'floors': floors,
        'capacity_per_floor': capacityPerFloor,
        'total_capacity': totalCapacity,
        'price_per_hour': pricePerHour,
        'photo_url': photoUrl,
        'status': 'pending',
      });
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Gagal mengirim pengajuan: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Terjadi kesalahan: $e');
    }
  }

  /// Upload foto lahan ke Supabase Storage, return public URL.
  /// Pastikan bucket 'lot-photos' sudah dibuat di Supabase Storage
  /// (Storage > New bucket > beri nama "lot-photos", set public).
  Future<String> uploadLotPhoto(File file, String fileName) async {
    try {
      final storagePath = 'operator_registrations/$fileName';

      await _supabaseClient.storage
          .from('lot-photos')
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      return _supabaseClient.storage.from('lot-photos').getPublicUrl(storagePath);
    } on StorageException catch (e) {
      throw ServerException(message: 'Gagal mengunggah foto: ${e.message}');
    }
  }
}