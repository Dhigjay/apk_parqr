import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/payment/payment_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  Timer? _pollingTimer;
  RealtimeChannel? _paymentChannel;

  // ----------------------------------------------------------------
  // Resolve session ID: jika bukan UUID valid, buat session baru
  // ----------------------------------------------------------------
  Future<String> _resolveSessionId(
      SupabaseClient supabase, String sessionId) async {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    if (uuidRegex.hasMatch(sessionId)) return sessionId;

    // Session dummy — buat session nyata
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null)
      throw Exception('Autentikasi gagal. Harap login kembali.');

    // public.users.id == auth.uid() langsung (bukan auth_id terpisah)
    final userCheck = await supabase
        .from('users')
        .select('id')
        .eq('id', currentUser.id)
        .maybeSingle();

    if (userCheck == null) {
      throw Exception(
          'Profil user tidak ditemukan. Silakan lengkapi profil terlebih dahulu.');
    }

    final userId = userCheck['id'] as String;

    // Cari kendaraan user
    final vehicleQuery = await supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();

    if (vehicleQuery == null) {
      throw Exception(
          'Belum ada kendaraan terdaftar. Tambah kendaraan di halaman Profil.');
    }
    final vehicleId = vehicleQuery['id'] as String;

    // Cari parking lot aktif.
    var lotQuery = await supabase
        .from('parking_lots')
        .select('id')
        .eq('status', 'active')
        .limit(1)
        .maybeSingle();

    lotQuery ??= await supabase
        .from('parking_lots')
        .select('id')
        .limit(1)
        .maybeSingle();

    if (lotQuery == null) {
      throw Exception(
          'Tidak ada area parkir aktif. Silakan daftarkan operator terlebih dahulu.');
    }
    final lotId = lotQuery['id'] as String;

    // Buat session — nama kolom sesuai MASTER_SCHEMA_CLEAN.sql
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 24));
    final insertedSession = await supabase
        .from('parking_sessions')
        .insert({
          'user_id': userId,
          'vehicle_id': vehicleId,
          'lot_id': lotId,
          'status': 'active',
          'entry_qr_token': 'mock-entry-${now.millisecondsSinceEpoch}',
          'entry_qr_expires_at': expiresAt.toIso8601String(),
          'entered_at': now.toIso8601String(),
          'amount_due': 0,
        })
        .select('id')
        .single();

    return insertedSession['id'] as String;
  }

  // ----------------------------------------------------------------
  // Helper: insert ke tabel payments, return paymentId
  // ----------------------------------------------------------------
  // ----------------------------------------------------------------
  // Helper: insert ke tabel payments, return paymentId
  // ----------------------------------------------------------------
  Future<String> _createPaymentRecord(
    SupabaseClient supabase,
    String sessionId,
    double amount,
    String method,
  ) async {
    final response = await supabase
        
        .from('payments')
        
        .insert({
              'session_id': sessionId,
              'amount': amount,
              'method': method.toLowerCase().toLowerCase(),
              'status': 'pending',
            })
        
        .select('id')
        
        .single();
    return response['id'] as String;
  }

  // ----------------------------------------------------------------
  // Realtime listener untuk status pembayaran
  // ----------------------------------------------------------------
  // ----------------------------------------------------------------
  // Realtime listener untuk status pembayaran
  // ----------------------------------------------------------------
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
              } else if (status == 'failed' ||
                  status == 'expired' ||
                  status == 'cancelled') {
                emit(const PaymentFailed(
                    'Pembayaran dibatalkan atau kedaluwarsa.'));
              }
              _handlePaymentStatus(status, paymentId);
            },
          )
          .subscribe();

      // Tambahkan polling fallback karena kadang Realtime tidak aktif di Supabase project
      _pollingTimer?.cancel();
      _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
        try {
          final res = await supabase
              .from('payments')
              .select('status')
              .eq('id', paymentId)
              .maybeSingle();
          if (res != null) {
            _handlePaymentStatus(res['status'] as String?, paymentId);
          }
        } catch (e) {
          // Abaikan error polling agar tidak mengganggu UI
          print('DEBUG Polling error: $e');
        }
      });
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan mendeteksi pembayaran: $e'));
    }
  }

  void _handlePaymentStatus(String? status, String paymentId) {
    if (status == 'paid') {
      _pollingTimer?.cancel();
      _paymentChannel?.unsubscribe();
      emit(PaymentSuccess(
        exitQrPayload: '{"type":"EXIT","payment_id":"$paymentId"}',
      ));
    } else if (status == 'failed' ||
        status == 'expired' ||
        status == 'cancelled') {
      _pollingTimer?.cancel();
      _paymentChannel?.unsubscribe();
      emit(const PaymentFailed('Pembayaran dibatalkan atau kedaluwarsa.'));
    }
  }

  // ----------------------------------------------------------------
  // CASH
  // ----------------------------------------------------------------
  void processCashPayment({String sessionId = 'demo-session-001'}) async {
    emit(const PaymentProcessing(method: 'cash'));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);
      final paymentId = await _createPaymentRecord(
        supabase,
        resolvedSessionId,
        0,
        'cash',
      );

      await supabase
          .from('payments')
          .update({'status': 'waiting_operator'}).eq('id', paymentId);

      emit(PaymentAwaitingVerification());
      _listenToPayment(supabase, paymentId);
    } catch (e) {
      emit(PaymentFailed('Gagal memproses pembayaran cash: $e'));
    }
  }

  // ----------------------------------------------------------------
  // SNAP (QRIS + VA via Midtrans Snap)
  // ----------------------------------------------------------------
  void processSnapPayment(
      String sessionId, double amount, String method) async {
    emit(PaymentProcessing(method: method));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);
      final paymentId = await _createPaymentRecord(
        supabase,
        resolvedSessionId,
        amount,
        method.toLowerCase(),
      );

      final res = await supabase.functions.invoke(
        'midtrans_snap',
        body: {
          'payment_id': paymentId,
          'amount': amount.toInt(),
        },
      );

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
          emit(const PaymentFailed(
              'Gagal mendapatkan link pembayaran. Coba lagi.'));
        }
      } else {
        final errorMsg =
            res.data?['error']?.toString() ?? 'Error tidak diketahui';
        if (errorMsg.contains('MIDTRANS_SERVER_KEY')) {
          emit(const PaymentFailed(
            'Konfigurasi Midtrans belum lengkap.\n'
            'Admin: Set MIDTRANS_SERVER_KEY di Supabase → Settings → Edge Functions → Secrets',
          ));
        } else {
          emit(PaymentFailed('Gagal membuat pembayaran: $errorMsg'));
        }
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
