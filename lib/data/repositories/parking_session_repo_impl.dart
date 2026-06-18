import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/parking_session_entity.dart';
import '../../domain/repositories/i_parking_session_repository.dart';
import '../models/parking_session_model.dart';

class ParkingSessionRepoImpl implements IParkingSessionRepository {
  final SupabaseClient _supabaseClient;
  final Uuid _uuid = const Uuid();

  ParkingSessionRepoImpl(this._supabaseClient);

  @override
  Future<ParkingSessionEntity> bookParkingSlot({
    required String userId,
    required String vehicleId,
    required String parkingLotId,
    String? parkingSlotId,
  }) async {
    try {
      final sessionId = _uuid.v4();
      final now = DateTime.now();
      
      final entryQrPayload = generateEntryQrPayload(sessionId);

      final sessionModel = ParkingSessionModel(
        id: sessionId,
        userId: userId,
        vehicleId: vehicleId,
        parkingLotId: parkingLotId,
        parkingSlotId: parkingSlotId,
        entryTime: now,
        status: 'booked',
        entryQrPayload: entryQrPayload,
        createdAt: now,
      );

      final response = await _supabaseClient
          .from('parking_sessions')
          .insert(sessionModel.toJson())
          .select()
          .single();

      return ParkingSessionModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to book parking slot: $e');
    }
  }

  @override
  String generateEntryQrPayload(String sessionId) {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 24));
    
    final payload = {
      'session_id': sessionId,
      'type': 'entry',
      'issued_at': now.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'nonce': _uuid.v4(),
    };
    
    return jsonEncode(payload);
  }

  @override
  bool validateQrExpiration(String payloadString) {
    try {
      final payload = jsonDecode(payloadString) as Map<String, dynamic>;
      final expiresAtStr = payload['expires_at'] as String?;
      
      if (expiresAtStr == null) return false;
      
      final expiresAt = DateTime.parse(expiresAtStr);
      final now = DateTime.now();
      
      return now.isBefore(expiresAt);
    } catch (e) {
      return false; // Invalid payload format
    }
  }
}
