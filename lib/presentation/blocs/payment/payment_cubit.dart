import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/presentation/blocs/payment/payment_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(PaymentInitial());

  Timer? _pollingTimer;

  void processCashPayment() async {
    emit(const PaymentProcessing(method: 'Cash'));
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
      
      final response = await supabase.from('payments').insert({
        'parking_session_id': sessionId,
        'amount': amount,
        'method': 'QRIS',
        'status': 'PENDING',
      }).select().single();
      
      final paymentId = response['id'];

      final res = await supabase.functions.invoke(
        'midtrans_charge',
        body: {
          'payment_id': paymentId,
          'amount': amount,
          'method': 'QRIS',
        },
      );
      
      String qrisUrl = '';
      if (res.status == 200 && res.data != null && res.data['data'] != null) {
        qrisUrl = res.data['data']['qris_url'] ?? '';
      }

      emit(PaymentQrisGenerated(qrisUrl: qrisUrl, paymentId: paymentId));

      _listenToPayment(supabase, paymentId);
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan: $e'));
    }
  }

  void processVaPayment(String sessionId, double amount, String bank) async {
    emit(PaymentProcessing(method: 'VA_$bank'));
    
    try {
      final supabase = Supabase.instance.client;
      
      final response = await supabase.from('payments').insert({
        'parking_session_id': sessionId,
        'amount': amount,
        'method': 'VA_$bank',
        'status': 'PENDING',
      }).select().single();
      
      final paymentId = response['id'];

      final res = await supabase.functions.invoke(
        'midtrans_charge',
        body: {
          'payment_id': paymentId,
          'amount': amount,
          'method': 'VA',
          'bank': bank,
        },
      );
      
      String vaNumber = '';
      if (res.status == 200 && res.data != null && res.data['data'] != null) {
        vaNumber = res.data['data']['va_number'] ?? '';
      }

      emit(PaymentVaGenerated(vaNumber: vaNumber, bank: bank, paymentId: paymentId));

      _listenToPayment(supabase, paymentId);
    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan: $e'));
    }
  }

  void _listenToPayment(SupabaseClient supabase, String paymentId) {
    supabase.channel('public:payments')
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
            final status = payload.newRecord['status'];
            if (status == 'PAID') {
              // Get exit QR payload (mocking for MVP, or could call Edge function)
              emit(PaymentSuccess(exitQrPayload: '{"type":"EXIT", "payment_id":"$paymentId"}'));
            } else if (status == 'FAILED') {
              emit(const PaymentFailed('Pembayaran dibatalkan atau kedaluwarsa'));
            }
          }
        ).subscribe();

    } catch (e) {
      emit(PaymentFailed('Terjadi kesalahan: $e'));
    }
  }

  void cancelPayment() {
    _pollingTimer?.cancel();
    emit(PaymentInitial());
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
