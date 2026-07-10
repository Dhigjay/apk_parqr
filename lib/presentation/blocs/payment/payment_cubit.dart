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
    // Simulate API call to notify operator
    await Future.delayed(const Duration(seconds: 1));
    emit(PaymentAwaitingVerification());

    // Simulate operator verifying cash payment after 3 seconds
    _pollingTimer = Timer(const Duration(seconds: 3), () {
      emit(const PaymentSuccess(exitQrPayload: 'EXIT-QR-PAYLOAD-123'));
    });
  }

  Future<String> _resolveSessionId(SupabaseClient supabase, String sessionId) async {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    if (uuidRegex.hasMatch(sessionId)) {
      return sessionId;
    }

    // It's a dummy session ID (like 'demo-session-001'). Resolve/create dynamically.
    final currentUser = supabase.auth.currentUser;
    if (currentUser == null) {
      throw Exception('Autentikasi gagal. Harap login kembali.');
    }

    // 1. Get or create vehicle for the current user
    String vehicleId;
    final vehicleQuery = await supabase
        .from('vehicles')
        .select('id')
        .eq('user_id', currentUser.id)
        .limit(1)
        .maybeSingle();

    if (vehicleQuery == null) {
      // Verify user exists in users table before inserting vehicle
      final userCheck = await supabase
          .from('users')
          .select('id')
          .eq('id', currentUser.id)
          .maybeSingle();
      
      if (userCheck == null) {
        throw Exception('User profile belum lengkap. Silakan lengkapi profil terlebih dahulu.');
      }

      final insertedVehicle = await supabase.from('vehicles').insert({
        'user_id': currentUser.id,
        'brand': 'Mock Toyota',
        'model': 'Avanza',
        'vehicle_type': 'mobil',
        'plate_number': 'B 1234 DEMO',
        'is_primary': true,
      }).select('id').single();
      vehicleId = insertedVehicle['id'] as String;
    } else {
      vehicleId = vehicleQuery['id'] as String;
    }

    // 2. Find any active parking lot in database
    final lotQuery = await supabase
        .from('parking_lots')
        .select('id')
        .eq('status', 'active')
        .limit(1)
        .maybeSingle();

    if (lotQuery == null) {
      throw Exception('Tidak ada area parkir aktif di database. Silakan daftarkan operator/area parkir terlebih dahulu.');
    }
    final lotId = lotQuery['id'] as String;

    // 3. Create a real parking session in the database
    final now = DateTime.now();
    final insertedSession = await supabase.from('parking_sessions').insert({
      'user_id': currentUser.id,
      'vehicle_id': vehicleId,
      'lot_id': lotId,
      'status': 'active',
      'entry_qr_token': 'mock-entry-${now.millisecondsSinceEpoch}',
      'entry_qr_expires_at': now.add(const Duration(days: 1)).toIso8601String(),
      'entered_at': now.toIso8601String(),
    }).select('id').single();

    return insertedSession['id'] as String;
  }

  void processQrisPayment(String sessionId, double amount) async {
    emit(const PaymentProcessing(method: 'QRIS'));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);

      // 1. Insert payment record with correct column name and lowercase values
      final response = await supabase.from('payments').insert({
        'session_id': resolvedSessionId,       // ← fixed: was 'parking_session_id'
        'amount': amount,
        'method': 'qris',              // ← fixed: was 'QRIS' (uppercase)
        'status': 'pending',           // ← fixed: was 'PENDING' (uppercase)
      }).select().single();

      final paymentId = response['id'] as String;

      // 2. Call edge function to get QRIS URL from Midtrans Sandbox
      final res = await supabase.functions.invoke(
        'midtrans_charge',
        body: {
          'payment_id': paymentId,
          'amount': amount.toInt(),    // Midtrans expects integer (IDR has no cents)
          'method': 'QRIS',
        },
      );

      // Enhanced error handling and logging
      print('🔍 Midtrans Charge Response:');
      print('   Status: ${res.status}');
      print('   Data: ${res.data}');

      String qrisUrl = '';
      if (res.status == 200 && res.data != null) {
        if (res.data['data'] != null && res.data['data']['qris_url'] != null) {
          qrisUrl = res.data['data']['qris_url'] ?? '';
          print('✅ QRIS URL berhasil didapat: $qrisUrl');
        } else {
          print('⚠️ Response 200 tapi data kosong: ${res.data}');
          emit(const PaymentFailed('Midtrans tidak mengembalikan QRIS URL. Cek konfigurasi MIDTRANS_SERVER_KEY di Supabase.'));
          return;
        }
      } else if (res.data != null && res.data['error'] != null) {
        final errorMsg = res.data['error'].toString();
        print('❌ Error dari Midtrans: $errorMsg');
        
        // Check for common configuration errors
        if (errorMsg.contains('MIDTRANS_SERVER_KEY')) {
          emit(const PaymentFailed(
            'Konfigurasi Midtrans belum lengkap.\n\n'
            'Admin: Set MIDTRANS_SERVER_KEY di Supabase Dashboard → Settings → Edge Functions → Secrets'
          ));
        } else {
          emit(PaymentFailed('Gagal membuat QRIS: $errorMsg'));
        }
        return;
      } else {
        print('❌ Response status tidak 200: ${res.status}');
        emit(PaymentFailed('Gagal membuat QRIS (status ${res.status}). Cek logs Supabase Edge Function.'));
        return;
      }

      // 3. Emit state with QRIS URL so UI can display QR code
      emit(PaymentQrisGenerated(qrisUrl: qrisUrl, paymentId: paymentId));

      // 4. Listen for webhook-triggered status changes via Realtime
      _listenToPayment(supabase, paymentId);
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan: $e'));
    }
  }

  void processVaPayment(String sessionId, double amount, String bank) async {
    emit(PaymentProcessing(method: 'VA_$bank'));

    try {
      final supabase = Supabase.instance.client;
      final resolvedSessionId = await _resolveSessionId(supabase, sessionId);

      // 1. Insert payment record with correct column name and lowercase values
      final response = await supabase.from('payments').insert({
        'session_id': resolvedSessionId,           // ← fixed: was 'parking_session_id'
        'amount': amount,
        'method': 'va_${bank.toLowerCase()}',  // ← fixed: was 'VA_$bank'
        'status': 'pending',               // ← fixed: was 'PENDING'
      }).select().single();

      final paymentId = response['id'] as String;

      // 2. Call edge function to get VA number from Midtrans Sandbox
      final res = await supabase.functions.invoke(
        'midtrans_charge',
        body: {
          'payment_id': paymentId,
          'amount': amount.toInt(),        // Midtrans expects integer
          'method': 'VA',
          'bank': bank.toLowerCase(),      // 'bca', 'bni', 'bri'
        },
      );

      // Enhanced error handling and logging
      print('🔍 Midtrans VA Response:');
      print('   Status: ${res.status}');
      print('   Data: ${res.data}');

      String vaNumber = '';
      if (res.status == 200 && res.data != null) {
        if (res.data['data'] != null && res.data['data']['va_number'] != null) {
          vaNumber = res.data['data']['va_number'] ?? '';
          print('✅ VA Number berhasil didapat: $vaNumber');
        } else {
          print('⚠️ Response 200 tapi data kosong: ${res.data}');
          emit(const PaymentFailed('Midtrans tidak mengembalikan nomor VA. Cek konfigurasi MIDTRANS_SERVER_KEY di Supabase.'));
          return;
        }
      } else if (res.data != null && res.data['error'] != null) {
        final errorMsg = res.data['error'].toString();
        print('❌ Error dari Midtrans: $errorMsg');
        
        // Check for common configuration errors
        if (errorMsg.contains('MIDTRANS_SERVER_KEY')) {
          emit(const PaymentFailed(
            'Konfigurasi Midtrans belum lengkap.\n\n'
            'Admin: Set MIDTRANS_SERVER_KEY di Supabase Dashboard → Settings → Edge Functions → Secrets'
          ));
        } else {
          emit(PaymentFailed('Gagal membuat Virtual Account: $errorMsg'));
        }
        return;
      } else {
        print('❌ Response status tidak 200: ${res.status}');
        emit(PaymentFailed('Gagal membuat VA (status ${res.status}). Cek logs Supabase Edge Function.'));
        return;
      }

      // 3. Emit state with VA number so UI can display it
      emit(PaymentVaGenerated(vaNumber: vaNumber, bank: bank, paymentId: paymentId));

      // 4. Listen for webhook-triggered status changes via Realtime
      _listenToPayment(supabase, paymentId);
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan: $e'));
    }
  }

  void _listenToPayment(SupabaseClient supabase, String paymentId) {
    try {
      // Unsubscribe from any existing channel first
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
