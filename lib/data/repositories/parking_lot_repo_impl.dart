import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/parking_lot_entity.dart';
import '../../domain/entities/parking_slot_entity.dart';
import '../../domain/repositories/i_parking_lot_repository.dart';
import '../models/parking_lot_model.dart';
import '../models/parking_slot_model.dart';

class ParkingLotRepoImpl implements IParkingLotRepository {
  final SupabaseClient _supabaseClient;

  ParkingLotRepoImpl(this._supabaseClient);

  @override
  Future<List<ParkingLotEntity>> searchParkingLots(String query) async {
    try {
      final response = await _supabaseClient
          .from('parking_lots')
          .select()
          .ilike('name', '%$query%');

      return (response as List)
          .map((json) => ParkingLotModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search parking lots: $e');
    }
  }

  @override
  Future<ParkingLotEntity> getParkingLotDetail(String id) async {
    try {
      final response = await _supabaseClient
          .from('parking_lots')
          .select()
          .eq('id', id)
          .single();

      return ParkingLotModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get parking lot detail: $e');
    }
  }

  @override
  Future<List<ParkingSlotEntity>> getAvailableSlots(String parkingLotId) async {
    try {
      final response = await _supabaseClient
          .from('parking_slots')
          .select()
          .eq('parking_lot_id', parkingLotId)
          .eq('is_available', true);

      return (response as List)
          .map((json) => ParkingSlotModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get available slots: $e');
    }
  }
}
