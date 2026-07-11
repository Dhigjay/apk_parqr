import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/payment/payment_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  Timer? _pollingTimer;
  RealtimeChannel? _paymentChannel;

  void processCashPayment() async {
    emit(const PaymentProcessing(method: 'cash'));
    await Future.delayed(const Duration(seconds: 1));
    emit(PaymentAwaitingVerification());

    _pollingTimer = Timer(const Duration(seconds: 3), () {
      emit(const PaymentSuccess(exitQrPayload: 'EXIT-QR-PAYLOAD-123'));
    });
  }

  Future<String> _resolveSessionId(SupabaseClient supabase, String sessionId) async {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );

    // Kalau sudah UUID valid, langsung return
    if (uuidRegex.hasMatch(sessionId)) {
      return sessionId;
    }

    // Session dummy — resolve ke session nyata
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Autentikasi gagal. Harap login kembali.');
    }

    // ✅ FIX 1: Cari user pakai auth_id, bukan id
    final userCheck = await supabase
        .from('users')
        .select('id')
        .eq('auth_id', currentUser.id)
        .maybeSingle();

    if (userCheck == null) {
      throw Exception('Profil user tidak ditemukan. Silakan lengkapi profil terlebih dahulu.');
    }

    // ✅ Ambil internal UUID dari tabel users (bukan auth UUID)
    final userId = userCheck['id'] as String;

    // ✅ FIX 2: Cari kendaraan pakai userId (internal), bukan currentUser.id
    String vehicleId;
    final vehicleQuery = await supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', userId)
        .limit(1)
        .maybeSingle();

    if (vehicleQuery == null) {
      // Buat kendaraan dummy jika belum ada
      final insertedVehicle = await supabase.from('vehicles').insert({
        'user_id': userId,           // ✅ pakai internal userId
        'brand': 'Mock Toyota',
        'model': 'Avanza',
        'vehicle_type': 'mobil',
        'plate_number': 'B 1234 DEMO',
      }).select('id').single();
      vehicleId = insertedVehicle['id'] as String;
    } else {
      vehicleId = vehicleQuery['id'] as String;
    }

    // Cari parking lot aktif
    final lotQuery = await supabase
        .from('parking_lots')
        .select('id')
        .eq('status', 'active')
        .limit(1)
        .maybeSingle();

    if (lotQuery == null) {
      throw Exception('Tidak ada area parkir aktif. Silakan daftarkan operator terlebih dahulu.');
    }
    final lotId = lotQuery['id'] as String;

    // ✅ FIX 3: Buat parking session dengan nama kolom yang benar sesuai schema
    final now = DateTime.now();
    final insertedSession = await supabase.from('parking_sessions').insert({
      'user_id': userId,                                          // ✅ internal userId
      'vehicle_id': vehicleId,
      'parking_lot_id': lotId,                                   // ✅ fix: bukan 'lot_id'
      'status': 'active',
      'check_in_time': now.toIso8601String(),                    // ✅ fix: bukan 'entered_at'
      'entry_qr_code': 'mock-entry-${now.millisecondsSinceEpoch}', // ✅ fix: bukan 'entry_qr_token'
    }).select('id').single();

    return insertedSession['id'] as String;
  }

  void processQrisPayment(String sessionId, double amount) async {
    emit(const PaymentProcessing(method: 'QRIS'));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);

      final response = await supabase.from('payments').insert({
        'session_id': resolvedSessionId,
        'amount': amount,
        'method': 'qris',
        'status': 'pending',
      }).select().single();

      final paymentId = response['id'] as String;

      final res = await supabase.functions.invoke(
        'midtrans_charge',
        body: {
          'payment_id': paymentId,
          'amount': amount.toInt(),
          'method': 'QRIS',
        },
      );

      print('🔍 Midtrans Charge Response:');
      print('   Status: ${res.status}');
      print('   Data: ${res.data}');

      if (res.status == 200 && res.data != null) {
        final qrisUrl = res.data['data']?['qris_url'] as String?;
        if (qrisUrl != null && qrisUrl.isNotEmpty) {
          print('✅ QRIS URL berhasil didapat: $qrisUrl');
          emit(PaymentQrisGenerated(qrisUrl: qrisUrl, paymentId: paymentId));
          _listenToPayment(supabase, paymentId);
        } else {
          print('⚠️ Response 200 tapi qris_url kosong: ${res.data}');
          emit(const PaymentFailed(
            'Midtrans tidak mengembalikan QRIS URL. '
            'Cek konfigurasi MIDTRANS_SERVER_KEY di Supabase.',
          ));
        }
      } else {
        final errorMsg = res.data?['error']?.toString() ?? 'Unknown error';
        print('❌ Error dari Midtrans: $errorMsg (status ${res.status})');

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

  void processVaPayment(String sessionId, double amount, String bank) async {
    emit(PaymentProcessing(method: 'VA_$bank'));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);

      final response = await supabase.from('payments').insert({
        'session_id': resolvedSessionId,
        'amount': amount,
        'method': 'va_${bank.toLowerCase()}',
        'status': 'pending',
      }).select().single();

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

      print('🔍 Midtrans VA Response:');
      print('   Status: ${res.status}');
      print('   Data: ${res.data}');

      if (res.status == 200 && res.data != null) {
        final vaNumber = res.data['data']?['va_number'] as String?;
        if (vaNumber != null && vaNumber.isNotEmpty) {
          print('✅ VA Number berhasil didapat: $vaNumber');
          emit(PaymentVaGenerated(vaNumber: vaNumber, bank: bank, paymentId: paymentId));
          _listenToPayment(supabase, paymentId);
        } else {
          print('⚠️ Response 200 tapi va_number kosong: ${res.data}');
          emit(const PaymentFailed(
            'Midtrans tidak mengembalikan nomor VA. '
            'Cek konfigurasi MIDTRANS_SERVER_KEY di Supabase.',
          ));
        }
      } else {
        final errorMsg = res.data?['error']?.toString() ?? 'Unknown error';
        print('❌ Error dari Midtrans: $errorMsg (status ${res.status})');

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
                emit(const PaymentFailed('Pembayaran dibatalkan atau kedaluwarsa.'));
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