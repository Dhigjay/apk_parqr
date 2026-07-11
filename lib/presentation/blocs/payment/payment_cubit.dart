import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/payment/payment_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  Timer? _pollingTimer;
  RealtimeChannel? _paymentChannel;

  // ----------------------------------------------------------------
  // CASH
  // ----------------------------------------------------------------
  void processCashPayment({String sessionId = 'demo-session-001'}) async {
    emit(const PaymentProcessing(method: 'cash'));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);

      // Insert payment record
      final response = await supabase
          .from('payments')
          .insert({
            'session_id': resolvedSessionId,
            'amount': 0, // akan di-update saat verifikasi operator
            'method': 'cash',
            'status': 'waiting_operator',
          })
          .select()
          .single();

      final paymentId = response['id'] as String;

      emit(PaymentAwaitingVerification());

      // Dengarkan perubahan status via Realtime
      _listenToPayment(supabase, paymentId);
    } catch (e) {
      emit(PaymentFailed('Gagal memproses pembayaran cash: $e'));
    }
  }

  // ----------------------------------------------------------------
  // Resolve session ID: jika bukan UUID valid, buat session baru
  // ----------------------------------------------------------------
  Future<String> _resolveSessionId(
      SupabaseClient supabase, String sessionId) async {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    if (uuidRegex.hasMatch(sessionId)) return sessionId;

    // Session dummy — buat session nyata di database
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Autentikasi gagal. Harap login kembali.');
    }

    // Kolom 'id' di public.users = auth.uid() langsung (bukan 'auth_id')
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
    String vehicleId;
    final vehicleQuery = await supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();

    if (vehicleQuery == null) {
      final insertedVehicle = await supabase
          .from('vehicles')
          .insert({
            'user_id': userId,
            'brand': 'Mock Toyota',
            'model': 'Avanza',
            'vehicle_type': 'mobil',
            'plate_number': 'B 1234 DEMO',
            'is_primary': true,
          })
          .select('id')
          .single();
      vehicleId = insertedVehicle['id'] as String;
    } else {
      vehicleId = vehicleQuery['id'] as String;
    }

    // Cari parking lot aktif — field 'is_active' sesuai MASTER_SCHEMA_CLEAN.sql
    final lotQuery = await supabase
        .from('parking_lots')
        .select('id')
        .eq('is_active', true)
        .limit(1)
        .maybeSingle();

    if (lotQuery == null) {
      throw Exception(
          'Tidak ada area parkir aktif. Silakan daftarkan operator terlebih dahulu.');
    }
    final lotId = lotQuery['id'] as String;

    // Buat session — nama kolom sesuai schema:
    // lot_id | entry_qr_token | entry_qr_expires_at | entered_at
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
  // QRIS
  // ----------------------------------------------------------------
  void processQrisPayment(String sessionId, double amount) async {
    emit(const PaymentProcessing(method: 'QRIS'));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);

      final response = await supabase
          .from('payments')
          .insert({
            'session_id': resolvedSessionId,
            'amount': amount,
            'method': 'qris',
            'status': 'pending',
          })
          .select()
          .single();

      final paymentId = response['id'] as String;

      final res = await supabase.functions.invoke(
        'midtrans_charge',
        body: {
          'payment_id': paymentId,
          'amount': amount.toInt(),
          'method': 'QRIS',
        },
      );

      if (res.status == 200 && res.data != null) {
        final qrisUrl = res.data['data']?['qris_url'] as String?;
        if (qrisUrl != null && qrisUrl.isNotEmpty) {
          emit(PaymentQrisGenerated(qrisUrl: qrisUrl, paymentId: paymentId));
          _listenToPayment(supabase, paymentId);
        } else {
          emit(const PaymentFailed(
            'Midtrans tidak mengembalikan QRIS URL. '
            'Cek konfigurasi MIDTRANS_SERVER_KEY di Supabase.',
          ));
        }
      } else {
        final errorMsg = res.data?['error']?.toString() ?? 'Unknown error';
        if (errorMsg.contains('MIDTRANS_SERVER_KEY')) {
          emit(const PaymentFailed(
            'Konfigurasi Midtrans belum lengkap.\n\n'
            'Admin: Set MIDTRANS_SERVER_KEY di Supabase Dashboard → '
            'Settings → Edge Functions → Secrets',
          ));
        } else {
          emit(PaymentFailed('Gagal membuat QRIS: $errorMsg'));
        }
      }
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan: $e'));
    }
  }

  // ----------------------------------------------------------------
  // VIRTUAL ACCOUNT
  // ----------------------------------------------------------------
  void processVaPayment(String sessionId, double amount, String bank) async {
    emit(PaymentProcessing(method: 'VA_$bank'));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);

      final response = await supabase
          .from('payments')
          .insert({
            'session_id': resolvedSessionId,
            'amount': amount,
            'method': 'va_${bank.toLowerCase()}',
            'status': 'pending',
          })
          .select()
          .single();

      final paymentId = response['id'] as String;

      final res = await supabase.functions.invoke(
        'midtrans_charge',
        body: {
          'payment_id': paymentId,
          'amount': amount.toInt(),
          'method': 'VA',
          'bank': bank.toLowerCase(),
        },
      );

      if (res.status == 200 && res.data != null) {
        final vaNumber = res.data['data']?['va_number'] as String?;
        if (vaNumber != null && vaNumber.isNotEmpty) {
          emit(PaymentVaGenerated(
              vaNumber: vaNumber, bank: bank, paymentId: paymentId));
          _listenToPayment(supabase, paymentId);
        } else {
          emit(const PaymentFailed(
            'Midtrans tidak mengembalikan nomor VA. '
            'Cek konfigurasi MIDTRANS_SERVER_KEY di Supabase.',
          ));
        }
      } else {
        final errorMsg = res.data?['error']?.toString() ?? 'Unknown error';
        if (errorMsg.contains('MIDTRANS_SERVER_KEY')) {
          emit(const PaymentFailed(
            'Konfigurasi Midtrans belum lengkap.\n\n'
            'Admin: Set MIDTRANS_SERVER_KEY di Supabase Dashboard → '
            'Settings → Edge Functions → Secrets',
          ));
        } else {
          emit(PaymentFailed('Gagal membuat Virtual Account: $errorMsg'));
        }
      }
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan: $e'));
    }
  }

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
            },
          )
          .subscribe();
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan mendeteksi pembayaran: $e'));
    }
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
