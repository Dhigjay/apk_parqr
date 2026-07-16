import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/data/models/operator_registration_model.dart';
import 'package:parqr/data/models/admin_stats_model.dart';
import 'package:parqr/core/error/exceptions.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/data/datasources/remote/notification_remote_ds.dart';

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

  /// Helper: ambil id internal (public.users.id) dari admin yang sedang login.
  /// Dipakai untuk mengisi kolom reviewed_by, BUKAN auth.currentUser.id langsung,
  /// karena reviewed_by adalah FK ke public.users.id.
  Future<String> _getCurrentInternalUserId() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) {
      throw ServerException(message: 'Admin belum login.');
    }
    final row = await supabase
        .from('users')
        .select('id')
        .eq('auth_id', authUser.id)
        .single();
    return row['id'] as String;
  }

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

  /// Approve = 3 langkah dalam satu alur:
  /// 1. Ambil data registrasi (perlu applicant_user_id & detail lahan)
  /// 2. Update status registrasi jadi 'approved' + isi reviewed_by/reviewed_at
  /// 3. Update role user pendaftar jadi 'operator'
  /// 4. Buat parking_lot baru dari data registrasi
  ///
  /// Catatan: Supabase Dart client (PostgREST) tidak punya transaction
  /// multi-statement bawaan, jadi langkah ini dilakukan berurutan.
  /// Kalau salah satu gagal di tengah, data bisa jadi tidak konsisten —
  /// untuk produksi sebaiknya ini dipindah ke Postgres function (RPC)
  /// supaya atomic. Untuk sekarang, ini cukup untuk alur normal.
  @override
  Future<void> approveOperator(String id) async {
    try {
      final reviewerId = await _getCurrentInternalUserId();

      // 1. Ambil data registrasi yang mau di-approve
      final registration = await supabase
          .from('operator_registrations')
          .select()
          .eq('id', id)
          .single();

      final applicantUserId = registration['applicant_user_id'] as String;

      // 2. Update status registrasi
      await supabase.from('operator_registrations').update({
        'status': 'approved',
        'reviewed_by': reviewerId,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // 3. Update role user jadi operator
      await supabase
          .from('users')
          .update({'role': 'operator'}).eq('id', applicantUserId);

      // 4. Buat parking_lot baru dari data registrasi
      await supabase.from('parking_lots').insert({
        'owner_id': applicantUserId,
        'name': registration['business_name'],
        'address': registration['address'],
        'latitude': registration['latitude'],
        'longitude': registration['longitude'],
        'total_capacity': registration['total_capacity'],
        'floors': registration['floors'],
        'hourly_rate': registration['price_per_hour'],
        'photo_url': registration['photo_url'],
        'status': 'active',
      });

      try {
        await sl<NotificationRemoteDataSource>().createNotification(
          title: 'Pendaftaran Operator Disetujui',
          body:
              'Selamat! Pendaftaran Anda sebagai operator untuk ${registration['business_name']} telah disetujui.',
          type: 'operator_approved',
          userId: applicantUserId,
        );
      } catch (_) {}
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> rejectOperator(String id, String reason) async {
    try {
      final reviewerId = await _getCurrentInternalUserId();

      final response = await supabase
          .from('operator_registrations')
          .update({
            'status': 'rejected',
            'reject_reason': reason,
            'reviewed_by': reviewerId,
            'reviewed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      try {
        await sl<NotificationRemoteDataSource>().createNotification(
          title: 'Pendaftaran Operator Ditolak',
          body: 'Mohon maaf, pendaftaran Anda ditolak. Alasan: $reason',
          type: 'operator_rejected',
          userId: response['applicant_user_id'],
        );
      } catch (_) {}
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
      if (e.message.contains('Could not find the function') ||
          e.message.contains('schema cache') ||
          e.message.contains('functions')) {
        try {
          final usersResponse = await supabase.from('users').select('id');
          final users = usersResponse as List<dynamic>;

          final operatorsResponse =
              await supabase.from('users').select('id').eq('role', 'operator');
          final operators = operatorsResponse as List<dynamic>;

          final parkingLotsResponse =
              await supabase.from('parking_lots').select('id');
          final parkingLots = parkingLotsResponse as List<dynamic>;

          final sessionsResponse =
              await supabase.from('parking_sessions').select('id,status');
          final sessions = sessionsResponse as List<dynamic>;

          final paymentsResponse =
              await supabase.from('payments').select('amount,status,paid_at');
          final payments = paymentsResponse as List<dynamic>;

          final today = DateTime.now().toIso8601String().split('T').first;
          final totalRevenueToday = payments.where((payment) {
            final status = payment['status']?.toString().toLowerCase();
            final paidAt = payment['paid_at']?.toString();
            return status == 'paid' &&
                paidAt != null &&
                paidAt.startsWith(today);
          }).fold<double>(0.0, (sum, payment) {
            final amount = payment['amount'];
            if (amount is num) {
              return sum + amount.toDouble();
            }
            return sum;
          });

          final activeSessionsToday = sessions.where((session) {
            final status = session['status']?.toString().toLowerCase();
            return ['booked', 'active', 'checkout_requested', 'payment_pending']
                .contains(status);
          }).length;

          return AdminStatsModel(
            totalUsers: users.length,
            totalOperators: operators.length,
            totalParkingLots: parkingLots.length,
            activeSessionsToday: activeSessionsToday,
            totalRevenueToday: totalRevenueToday,
          );
        } catch (_) {
          throw ServerException(
              message: 'Gagal memuat statistik admin dari fallback query.');
        }
      }

      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
