import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/operator_registration_model.dart';
import '../../models/admin_stats_model.dart';
import '../../../core/error/exceptions.dart';

abstract class AdminRemoteDataSource {
  Future<List<OperatorRegistrationModel>> getPendingRegistrations();
  Future<OperatorRegistrationModel> getRegistrationDetail(String id);
  Future<void> approveOperator(String id);
  Future<void> rejectOperator(String id, String reason);
  Future<AdminStatsModel> getGlobalStats();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final SupabaseClient supabase;

  AdminRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<OperatorRegistrationModel>> getPendingRegistrations() async {
    try {
      final response = await supabase
          .from('operator_registrations')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => OperatorRegistrationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<OperatorRegistrationModel> getRegistrationDetail(String id) async {
    try {
      final response = await supabase
          .from('operator_registrations')
          .select()
          .eq('id', id)
          .single();
      
      return OperatorRegistrationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> approveOperator(String id) async {
    try {
      final response = await supabase.functions.invoke(
        'approve-operator',
        body: {'registration_id': id},
      );
      
      if (response.status != 200) {
        throw ServerException(message: 'Failed to approve operator: ${response.data}');
      }
    } on FunctionException catch (e) {
      throw ServerException(message: e.toString());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> rejectOperator(String id, String reason) async {
    try {
      await supabase
          .from('operator_registrations')
          .update({
            'status': 'rejected',
            'reject_reason': reason,
            'reviewed_by': supabase.auth.currentUser?.id,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<AdminStatsModel> getGlobalStats() async {
    try {
      final response = await supabase.rpc('get_global_stats');
      
      return AdminStatsModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
