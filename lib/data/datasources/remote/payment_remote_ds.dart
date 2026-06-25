import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:parqr/data/models/payment_model.dart';

abstract class IPaymentRemoteDataSource {
  Future<PaymentModel> createPayment(String sessionId, double amount, String paymentMethod);
  Future<PaymentModel> getPaymentStatus(String paymentId);
  Future<bool> verifyCashPayment(String paymentId, String operatorId);
  Future<String> generateExitQr(String paymentId);
}

class PaymentRemoteDataSourceImpl implements IPaymentRemoteDataSource {
  final SupabaseClient supabaseClient;

  PaymentRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<PaymentModel> createPayment(String sessionId, double amount, String paymentMethod) async {
    final response = await supabaseClient.from('payments').insert({
      'session_id': sessionId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': 'PENDING',
    }).select().single();

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
    // Insert into operator_verifications to log the cash verification
    await supabaseClient.from('operator_verifications').insert({
      'payment_id': paymentId,
      'operator_id': operatorId,
      'status': 'VERIFIED',
    });

    // Update payment status
    final response = await supabaseClient
        .from('payments')
        .update({'status': 'PAID'})
        .eq('id', paymentId)
        .select()
        .single();

    return response['status'] == 'PAID';
  }

  @override
  Future<String> generateExitQr(String paymentId) async {
    // Typically we'd call an Edge Function or format a payload string securely.
    // For now, generating a basic JSON payload.
    final payment = await getPaymentStatus(paymentId);
    if (payment.status != 'PAID') {
      throw Exception('Payment not paid. Cannot generate exit QR.');
    }
    
    // Return a JSON formatted string or token for QR
    return '{"type":"EXIT", "payment_id":"$paymentId", "session_id":"${payment.sessionId}"}';
  }
}
