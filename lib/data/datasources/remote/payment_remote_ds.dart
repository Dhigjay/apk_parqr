import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/data/models/payment_model.dart';

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

    final response = await supabaseClient
        .from('payments')
        .insert({
          'session_id': sessionId, // ✅ bukan 'parking_session_id'
          'amount': amount,
          'method': method, // ✅ lowercase
          'status': 'pending', // ✅ lowercase
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

    return response['status'] == 'paid';
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
