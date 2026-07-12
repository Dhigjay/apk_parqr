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

  /// Ambil internal user id dari public.users (bukan auth UID langsung).
  Future<String> _getCurrentInternalUserId() async {
    final authUid = supabaseClient.auth.currentUser?.id;
    if (authUid == null) throw Exception('User belum login.');
    final row = await supabaseClient
        .from('users')
        .select('id')
        .eq('auth_id', authUid)
        .single();
    return row['id'] as String;
  }

  @override
  Future<PaymentModel> createPayment(
      String sessionId, double amount, String paymentMethod) async {
    // Normalisasi method ke lowercase sesuai constraint DB
    final method = paymentMethod.toLowerCase(); // 'qris' atau 'cash'

    // Insert ke payments — pakai kolom 'session_id', bukan 'parking_session_id'
    final response = await supabaseClient.from('payments').insert({
      'session_id': sessionId,       // ✅ nama kolom yang benar
      'amount': amount,
      'method': method,              // ✅ lowercase: 'qris' / 'cash'
      'status': 'pending',           // ✅ lowercase sesuai constraint
    }).select().single();

    final paymentId = response['id'] as String;

    if (method == 'qris') {
      try {
        // Panggil Edge Function 'midtrans_change' (sesuai nama yang sudah di-deploy)
        final res = await supabaseClient.functions.invoke(
          'midtrans_change',         // ✅ nama function yang benar
          body: {
            'payment_id': paymentId,
            'amount': amount,
          },
        );

        if (res.status == 200) {
          // Edge function berhasil — ambil data terbaru dari DB
          final updatedResponse = await supabaseClient
              .from('payments')
              .select()
              .eq('id', paymentId)
              .single();
          return PaymentModel.fromJson(updatedResponse);
        } else {
          print('Edge function error: ${res.data}');
        }
      } on FunctionException catch (e) {
        print('FunctionException: ${e.status} ${e.details}');
        rethrow;
      } catch (e) {
        print('Error invoking edge function: $e');
        rethrow;
      }
    }

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
    // operatorId yang diterima harus sudah berupa public.users.id
    // (pastikan pemanggil sudah resolve internal id sebelum memanggil ini)
    await supabaseClient.from('operator_verifications').insert({
      'payment_id': paymentId,
      'operator_id': operatorId,
      'action': 'verified',          // ✅ sesuai constraint: 'verified' | 'rejected'
    });

    final response = await supabaseClient
        .from('payments')
        .update({'status': 'paid'})  // ✅ lowercase
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