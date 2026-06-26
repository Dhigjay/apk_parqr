import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/domain/entities/operator_registration_entity.dart';
import 'package:parqr/domain/entities/parking_session_entity.dart';
import 'package:parqr/domain/repositories/i_operator_repository.dart';
import 'package:parqr/data/models/operator_registration_model.dart';
import 'package:parqr/data/models/parking_session_model.dart';

class OperatorRepoImpl implements IOperatorRepository {
  final SupabaseClient _supabaseClient;

  OperatorRepoImpl(this._supabaseClient);

  @override
  Future<void> registerOperator(OperatorRegistrationEntity registration) async {
    try {
      final model = OperatorRegistrationModel(
        id: registration.id,
        applicantUserId: registration.applicantUserId,
        businessName: registration.businessName,
        address: registration.address,
        latitude: registration.latitude,
        longitude: registration.longitude,
        lotSizeM2: registration.lotSizeM2,
        floors: registration.floors,
        capacityPerFloor: registration.capacityPerFloor,
        totalCapacity: registration.totalCapacity,
        pricePerHour: registration.pricePerHour,
        photoUrl: registration.photoUrl,
        status: registration.status,
        rejectReason: registration.rejectReason,
        reviewedBy: registration.reviewedBy,
        reviewedAt: registration.reviewedAt,
        createdAt: registration.createdAt,
        updatedAt: registration.updatedAt,
      );

      await _supabaseClient
          .from('operator_registrations')
          .insert(model.toJson());
    } catch (e) {
      throw Exception('Failed to register operator: $e');
    }
  }

  @override
  Future<OperatorRegistrationEntity?> getOperatorRegistrationStatus(String userId) async {
    try {
      final response = await _supabaseClient
          .from('operator_registrations')
          .select()
          .eq('applicant_user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return OperatorRegistrationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get operator registration status: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats(String operatorId) async {
    try {
      final response = await _supabaseClient
          .rpc('get_operator_dashboard_stats', params: {'p_operator_id': operatorId});
      
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  @override
  Future<ParkingSessionEntity> scanCheckIn(String entryQrToken, String operatorId) async {
    try {
      // Find the session by token
      final sessionResponse = await _supabaseClient
          .from('parking_sessions')
          .select('*, parking_lots!inner(operator_id)')
          .eq('entry_qr_token', entryQrToken)
          .eq('status', 'booked')
          .single();

      if (sessionResponse['parking_lots']['operator_id'] != operatorId) {
        throw Exception('This QR code is not for your parking lot.');
      }

      // Update session status to active
      final updatedResponse = await _supabaseClient
          .from('parking_sessions')
          .update({
            'status': 'active',
            'entered_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', sessionResponse['id'])
          .select()
          .single();

      return ParkingSessionModel.fromJson(updatedResponse);
    } catch (e) {
      throw Exception('Failed to scan check-in: $e');
    }
  }

  @override
  Future<ParkingSessionEntity> scanCheckOut(String exitQrToken, String operatorId) async {
    try {
       // Find the session by token
      final sessionResponse = await _supabaseClient
          .from('parking_sessions')
          .select('*, parking_lots!inner(operator_id)')
          .eq('exit_qr_token', exitQrToken)
          .eq('status', 'paid')
          .single();

      if (sessionResponse['parking_lots']['operator_id'] != operatorId) {
        throw Exception('This QR code is not for your parking lot.');
      }

      // Update session status to completed
      final updatedResponse = await _supabaseClient
          .from('parking_sessions')
          .update({
            'status': 'completed',
            'exited_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', sessionResponse['id'])
          .select()
          .single();

      return ParkingSessionModel.fromJson(updatedResponse);
    } catch (e) {
      throw Exception('Failed to scan check-out: $e');
    }
  }

  @override
  Stream<List<ParkingSessionEntity>> listenToActiveSessions(String lotId) {
    return _supabaseClient
        .from('parking_sessions')
        .stream(primaryKey: ['id'])
        .map((events) => events
            .where((json) => json['lot_id'] == lotId && json['status'] == 'active')
            .map((json) => ParkingSessionModel.fromJson(json))
            .toList());
  }
}
