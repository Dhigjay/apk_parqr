import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/payment/payment_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  Timer? _pollingTimer;
  RealtimeChannel? _paymentChannel;

  Future<String> _getInternalUserId(SupabaseClient supabase) async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) throw Exception('Autentikasi gagal. Harap login kembali.');

    final userRow = await supabase
        .from('users')
        .select('id, is_profile_complete')
        .eq('auth_id', authUser.id)
        .maybeSingle();

    if (userRow == null) {
      throw Exception('Profil user tidak ditemukan. Silakan lengkapi profil terlebih dahulu.');
    }

    final isComplete = userRow['is_profile_complete'] as bool? ?? false;
    if (!isComplete) {
      throw Exception('Profil belum lengkap. Silakan isi nama dan alamat terlebih dahulu.');
    }

    return userRow['id'] as String;
  }

  Future<String> _resolveSessionId(SupabaseClient supabase, String sessionId) async {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    if (uuidRegex.hasMatch(sessionId)) return sessionId;

    final userId = await _getInternalUserId(supabase);

    final vehicleQuery = await supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();

    if (vehicleQuery == null) {
      throw Exception('Belum ada kendaraan terdaftar. Silakan tambahkan kendaraan terlebih dahulu.');
    }

    final lotQuery = await supabase
        .from('parking_lots')
        .select('id')
        .eq('status', 'active')
        .limit(1)
        .maybeSingle();

    if (lotQuery == null) throw Exception('Tidak ada area parkir aktif.');

    final now = DateTime.now();
    final insertedSession = await supabase.from('parking_sessions').insert({
      'user_id': userId,
      'vehicle_id': vehicleQuery['id'] as String,
      'parking_lot_id': lotQuery['id'] as String,
      'status': 'active',
      'check_in_time': now.toIso8601String(),
      'entry_qr_code': 'mock-entry-${now.millisecondsSinceEpoch}',
    }).select('id').single();

    return insertedSession['id'] as String;
  }

  Future<String> _createPaymentRecord(
    SupabaseClient supabase,
    String sessionId,
    double amount,
    String method,
  ) async {
    final response = await supabase.from('payments').insert({
      'session_id': sessionId,
      'amount': amount,
      'method': method,
      'status': 'pending',
    }).select('id').single();
    return response['id'] as String;
  }

  void _listenToPayment(SupabaseClient supabase, String paymentId) {
    try {
      _paymentChannel?.unsubscribe();
      _paymentChannel = supabase
          .channel('payment-status-$paymentId')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'payments',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: paymentId,
            ),
            callback: (payload) {
              final status = payload.newRecord['status'] as String?;
              if (status == 'paid') {
                emit(PaymentSuccess(
                  exitQrPayload: '{"type":"EXIT","payment_id":"$paymentId"}',
                ));
              } else if (status == 'failed' || status == 'expired' || status == 'cancelled') {
                emit(const PaymentFailed('Pembayaran dibatalkan atau kedaluwarsa.'));
              }
            },
          )
          .subscribe();
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan mendeteksi pembayaran: $e'));
    }
  }

  void processCashPayment() async {
    emit(const PaymentProcessing(method: 'cash'));
    await Future.delayed(const Duration(seconds: 1));
    emit(PaymentAwaitingVerification());
  }

  void processSnapPayment(String sessionId, double amount, String method) async {
    emit(PaymentProcessing(method: method));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);
      final paymentId = await _createPaymentRecord(
        supabase, resolvedSessionId, amount, method.toLowerCase(),
      );

      final res = await supabase.functions.invoke(
        'midtrans_snap',
        body: {
          'payment_id': paymentId,
          'amount': amount.toInt(),
        },
      );

      print('Snap Response: status=${res.status}, data=${res.data}');

      if (res.status == 200 && res.data != null) {
        final snapUrl = res.data['data']?['snap_url'] as String?;
        final snapToken = res.data['data']?['snap_token'] as String?;

        if (snapUrl != null && snapUrl.isNotEmpty) {
          final uri = Uri.parse(snapUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            emit(PaymentSnapOpened(
              snapUrl: snapUrl,
              snapToken: snapToken ?? '',
              paymentId: paymentId,
            ));
            _listenToPayment(supabase, paymentId);
          } else {
            emit(const PaymentFailed('Tidak bisa membuka halaman pembayaran.'));
          }
        } else {
          emit(const PaymentFailed('Gagal mendapatkan link pembayaran. Coba lagi.'));
        }
      } else {
        final errorMsg = res.data?['error']?.toString() ?? 'Error tidak diketahui';
        emit(PaymentFailed('Gagal membuat pembayaran: $errorMsg'));
      }
    } on FunctionException catch (e) {
      emit(PaymentFailed('Error Edge Function: ${e.details}'));
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan: $e'));
    }
  }

  void processQrisPayment(String sessionId, double amount) {
    processSnapPayment(sessionId, amount, 'qris');
  }

  void processVaPayment(String sessionId, double amount, String bank) {
    processSnapPayment(sessionId, amount, 'va_${bank.toLowerCase()}');
  }

  void cancelPayment() {
    _pollingTimer?.cancel();
    _paymentChannel?.unsubscribe();
    emit(PaymentInitial());
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _paymentChannel?.unsubscribe();
    return super.close();
  }
}