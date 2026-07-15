import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:parqr/data/models/vehicle_model.dart';

class VehicleRemoteDataSource {
  VehicleRemoteDataSource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  static const String vehiclePhotoBucket = 'vehicle-photos';

  final SupabaseClient _supabaseClient;

  /// Ambil Auth UID — hanya untuk validasi login & storage path.
  String get _currentAuthUid {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) throw StateError('User belum terautentikasi.');
    return userId;
  }

  /// Ambil internal id dari public.users (FK yang dipakai di tabel vehicles).
  /// TIDAK sama dengan auth.users.id — harus query ke public.users dulu.
  Future<String> _getCurrentInternalUserId() async {
    final authUid = _currentAuthUid;
    final row = await _supabaseClient
        .from('users')
        .select('id')
        .eq('auth_id', authUid)
        .single();
    return row['id'] as String;
  }

  Future<List<VehicleModel>> getMyVehicles() async {
    final userId = await _getCurrentInternalUserId();
    final data = await _supabaseClient
        .from('vehicles')
        .select()
        .eq('user_id', userId)
        .order('is_primary', ascending: false)
        .order('created_at');

    return data
        .map((row) => VehicleModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<VehicleModel> getVehicleById(String id) async {
    final userId = await _getCurrentInternalUserId();
    final data = await _supabaseClient
        .from('vehicles')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .single();

    return VehicleModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<VehicleModel> addVehicle({
    required String brand,
    required String model,
    required String vehicleType,
    required String plateNumber,
    String? photoUrl,
    bool isPrimary = false,
  }) async {
    final userId = await _getCurrentInternalUserId();

    final existingVehicles = await _supabaseClient
        .from('vehicles')
        .select('id')
        .eq('user_id', userId)
        .limit(1);
    final shouldBePrimary = isPrimary || existingVehicles.isEmpty;

    if (shouldBePrimary) {
      await _clearPrimaryVehicle(userId);
    }

    final data = await _supabaseClient
        .from('vehicles')
        .insert({
          'user_id': userId,            // ✅ public.users.id, bukan auth UID
          'brand': brand.trim(),
          'model': model.trim(),
          'vehicle_type': _normalizeVehicleType(vehicleType),
          'plate_number': _normalizePlateNumber(plateNumber),
          'photo_url': _blankToNull(photoUrl),
          'is_primary': shouldBePrimary,
          'is_active': true,
        })
        .select()
        .single();

    return VehicleModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<VehicleModel> updateVehicle({
    required String id,
    String? brand,
    String? model,
    String? vehicleType,
    String? plateNumber,
    String? photoUrl,
    bool? isPrimary,
  }) async {
    final userId = await _getCurrentInternalUserId();
    final payload = <String, dynamic>{
      if (brand != null) 'brand': brand.trim(),
      if (model != null) 'model': model.trim(),
      if (vehicleType != null) 'vehicle_type': _normalizeVehicleType(vehicleType),
      if (plateNumber != null) 'plate_number': _normalizePlateNumber(plateNumber),
      if (photoUrl != null) 'photo_url': _blankToNull(photoUrl),
      if (isPrimary != null) 'is_primary': isPrimary,
    };

    if (payload.isEmpty) return getVehicleById(id);

    if (isPrimary == true) {
      await _clearPrimaryVehicle(userId);
    }

    final data = await _supabaseClient
        .from('vehicles')
        .update(payload)
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single();

    return VehicleModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<String> uploadVehiclePhoto({
    required String vehicleId,
    required Uint8List bytes,
    required String fileExtension,
    String? contentType,
  }) async {
    await getVehicleById(vehicleId);

    final authUid = _currentAuthUid;
    final safeExtension = _sanitizeExtension(fileExtension);
    final fileName =
        '$vehicleId-${DateTime.now().millisecondsSinceEpoch}.$safeExtension';
    final objectPath = '$authUid/$fileName';

    await _supabaseClient.storage.from(vehiclePhotoBucket).uploadBinary(
          objectPath,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType ?? _contentTypeFor(safeExtension),
            upsert: true,
          ),
        );

    final photoUrl = _supabaseClient.storage
        .from(vehiclePhotoBucket)
        .getPublicUrl(objectPath);

    await updateVehicle(id: vehicleId, photoUrl: photoUrl);
    return photoUrl;
  }

  Future<VehicleModel> setPrimaryVehicle(String id) async {
    final userId = await _getCurrentInternalUserId();
    await getVehicleById(id);
    await _clearPrimaryVehicle(userId);

    final data = await _supabaseClient
        .from('vehicles')
        .update({'is_primary': true})
        .eq('id', id)
        .eq('user_id', userId)
        .select()
        .single();

    return VehicleModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteVehicle(String id) async {
    final userId = await _getCurrentInternalUserId();
    final deletedVehicle = await getVehicleById(id);

    await _supabaseClient
        .from('vehicles')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);

    if (!deletedVehicle.isPrimary) return;

    final remainingVehicles = await getMyVehicles();
    if (remainingVehicles.isNotEmpty) {
      await setPrimaryVehicle(remainingVehicles.first.id);
    }
  }

  Future<void> _clearPrimaryVehicle(String userId) async {
    await _supabaseClient
        .from('vehicles')
        .update({'is_primary': false})
        .eq('user_id', userId)
        .eq('is_primary', true);
  }
}

String _normalizeVehicleType(String vehicleType) {
  final normalized = vehicleType.trim().toLowerCase();
  if (normalized == 'motor' || normalized == 'mobil') return normalized;
  throw ArgumentError.value(
    vehicleType,
    'vehicleType',
    'Jenis kendaraan harus motor atau mobil.',
  );
}

String _normalizePlateNumber(String plateNumber) {
  return plateNumber.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
}

String? _blankToNull(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _sanitizeExtension(String extension) {
  final normalized = extension.replaceFirst('.', '').trim().toLowerCase();
  if (['jpeg', 'jpg', 'png', 'webp'].contains(normalized)) return normalized;
  return 'jpg';
}

String _contentTypeFor(String extension) {
  return switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };
}