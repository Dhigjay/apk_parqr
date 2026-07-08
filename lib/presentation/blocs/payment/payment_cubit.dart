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

  void processQrisPayment(String sessionId, double amount) async {
    emit(const PaymentProcessing(method: 'QRIS'));

    try {
      final supabase = Supabase.instance.client;

      // 1. Insert payment record with correct column name and lowercase values
      final response = await supabase.from('payments').insert({
        'session_id': sessionId,       // ← fixed: was 'parking_session_id'
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

      String qrisUrl = '';
      if (res.status == 200 && res.data != null && res.data['data'] != null) {
        qrisUrl = res.data['data']['qris_url'] ?? '';
      } else if (res.data != null && res.data['error'] != null) {
        emit(PaymentFailed('Gagal membuat QRIS: ${res.data['error']}'));
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

      // 1. Insert payment record with correct column name and lowercase values
      final response = await supabase.from('payments').insert({
        'session_id': sessionId,           // ← fixed: was 'parking_session_id'
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

      String vaNumber = '';
      if (res.status == 200 && res.data != null && res.data['data'] != null) {
        vaNumber = res.data['data']['va_number'] ?? '';
      } else if (res.data != null && res.data['error'] != null) {
        emit(PaymentFailed('Gagal membuat Virtual Account: ${res.data['error']}'));
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
