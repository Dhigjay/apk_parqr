import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/data/models/payment_model.dart';
import 'package:parqr/injection/injection_container.dart';
import 'package:parqr/data/datasources/remote/notification_remote_ds.dart';

bool shouldReuseExistingPaymentRecord(String? status) {
  final normalized = (status ?? '').trim().toLowerCase();
  return <String>[
    'pending',
    'waiting_operator',
    'failed',
    'expired',
    'cancelled'
  ].contains(normalized);
}

abstract class IPaymentRemoteDataSource {
  Future<PaymentModel> createPayment(
      String sessionId, double amount, String paymentMethod);
  Future<PaymentModel> getPaymentStatus(String paymentId);
  Future<bool> verifyCashPayment(String paymentId, String operatorId);
  Future<String> generateExitQr(String paymentId);
}

class PaymentRemoteDataSourceImpl implements IPaymentRemoteDataSource {
  final SupabaseClient supabaseClient;

  PaymentRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<PaymentModel> createPayment(
      String sessionId, double amount, String paymentMethod) async {
    final method = paymentMethod.toLowerCase();

    final existingResponse = await supabaseClient
        .from('payments')
        .select('id, status')
        .eq('session_id', sessionId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existingResponse != null &&
        shouldReuseExistingPaymentRecord(
            existingResponse['status']?.toString())) {
      final response = await supabaseClient
          .from('payments')
          .update({
            'amount': amount,
            'method': method,
            'status': 'pending',
          })
          .eq('id', existingResponse['id'])
          .select()
          .single();

      return PaymentModel.fromJson(response);
    }

    final response = await supabaseClient
        .from('payments')
        .insert({
          'session_id': sessionId,
          'amount': amount,
          'method': method,
          'status': 'pending',
        })
        .select()
        .single();

    return PaymentModel.fromJson(response);
  }

  @override
  Future<PaymentModel> getPaymentStatus(String paymentId) async {
    final response = await supabaseClient
        .from('payments')
        .select()
        .eq('id', paymentId)
        .single();

    return PaymentModel.fromJson(response);
  }

  @override
  Future<bool> verifyCashPayment(String paymentId, String operatorId) async {
    await supabaseClient.from('operator_verifications').insert({
      'payment_id': paymentId,
      'operator_id': operatorId,
      'amount': 0,
      'notes': 'Cash verified',
    });

    final response = await supabaseClient
        .from('payments')
        .update({'status': 'paid'}) // ✅ lowercase
        .eq('id', paymentId)
        .select()
        .single();

    final isPaid = response['status'] == 'paid';

    if (isPaid) {
      try {
        final sessionResponse = await supabaseClient
            .from('payments')
            .select('session_id')
            .eq('id', paymentId)
            .single();
        final userIdResponse = await supabaseClient
            .from('parking_sessions')
            .select('user_id')
            .eq('id', sessionResponse['session_id'])
            .single();
        await sl<NotificationRemoteDataSource>().createNotification(
          title: 'Pembayaran Berhasil',
          body: 'Pembayaran cash Anda berhasil diverifikasi.',
          type: 'payment_success',
          userId: userIdResponse['user_id'],
        );
      } catch (_) {}
    }

    return isPaid;
  }

  @override
  Future<String> generateExitQr(String paymentId) async {
    final payment = await getPaymentStatus(paymentId);
    if (payment.status.toLowerCase() != 'paid') {
      throw Exception('Payment belum lunas. Tidak bisa generate QR keluar.');
    }

    return '{"type":"EXIT","payment_id":"$paymentId","session_id":"${payment.sessionId}"}';
  }
}
