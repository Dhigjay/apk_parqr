import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/domain/entities/parking_lot_entity.dart';
import 'package:parqr/domain/entities/parking_slot_entity.dart';
import 'package:parqr/domain/repositories/i_parking_lot_repository.dart';
import 'package:parqr/data/models/parking_lot_model.dart';
import 'package:parqr/data/models/parking_slot_model.dart';

class ParkingLotRepoImpl implements IParkingLotRepository {
  final SupabaseClient _supabaseClient;

  ParkingLotRepoImpl(this._supabaseClient);

  @override
  Future<List<ParkingLotEntity>> searchParkingLots(String query) async {
    try {
      List<dynamic> response;
      if (query.isEmpty) {
        response = await _supabaseClient
            .from('parking_lots')
            .select()
            .eq('is_active', true)
            .order('created_at', ascending: false);
      } else {
        response = await _supabaseClient
            .from('parking_lots')
            .select()
            .eq('is_active', true)
            .ilike('name', '%$query%')
            .order('created_at', ascending: false);
      }

      return response
          .map((json) => ParkingLotModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mencari parkir: $e');
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

      return ParkingLotModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Gagal memuat detail parkir: $e');
    }
  }

  @override
  Future<List<ParkingSlotEntity>> getAvailableSlots(String lotId) async {
    try {
      final response = await _supabaseClient
          .from('parking_slots')
          .select()
          .eq('lot_id', lotId)
          .eq('status', 'available')
          .order('floor_number')
          .order('code');

      return (response as List)
          .map(
              (json) => ParkingSlotModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat slot parkir: $e');
    }
  }

  @override
  Future<void> createParkingLot(ParkingLotEntity lot) async {
    try {
      final model = ParkingLotModel(
        id: lot.id,
        operatorId: lot.operatorId,
        name: lot.name,
        address: lot.address,
        latitude: lot.latitude,
        longitude: lot.longitude,
        totalCapacity: lot.totalCapacity,
        totalFloors: lot.totalFloors,
        pricePerHour: lot.pricePerHour,
        photoUrl: lot.photoUrl,
        createdAt: lot.createdAt,
      );
      await _supabaseClient.from('parking_lots').insert(model.toJson());
    } catch (e) {
      throw Exception('Gagal membuat lahan parkir: $e');
    }
  }

  @override
  Future<void> updateParkingLot(ParkingLotEntity lot) async {
    try {
      final model = ParkingLotModel(
        id: lot.id,
        operatorId: lot.operatorId,
        name: lot.name,
        address: lot.address,
        latitude: lot.latitude,
        longitude: lot.longitude,
        totalCapacity: lot.totalCapacity,
        totalFloors: lot.totalFloors,
        pricePerHour: lot.pricePerHour,
        photoUrl: lot.photoUrl,
        createdAt: lot.createdAt,
      );
      await _supabaseClient
          .from('parking_lots')
          .update(model.toJson())
          .eq('id', lot.id);
    } catch (e) {
      throw Exception('Gagal mengupdate lahan parkir: $e');
    }
  }

  @override
  Future<void> addParkingSlot(ParkingSlotEntity slot) async {
    try {
      final model = ParkingSlotModel(
        id: slot.id,
        lotId: slot.lotId,
        code: slot.code,
        floorNumber: slot.floorNumber,
        status: slot.status,
      );
      await _supabaseClient.from('parking_slots').insert(model.toJson());
    } catch (e) {
      throw Exception('Gagal menambah slot parkir: $e');
    }
  }

  @override
  Future<void> updateParkingSlot(ParkingSlotEntity slot) async {
    try {
      final model = ParkingSlotModel(
        id: slot.id,
        lotId: slot.lotId,
        code: slot.code,
        floorNumber: slot.floorNumber,
        status: slot.status,
      );
      await _supabaseClient
          .from('parking_slots')
          .update(model.toJson())
          .eq('id', slot.id);
    } catch (e) {
      throw Exception('Gagal mengupdate slot parkir: $e');
    }
  }
}
