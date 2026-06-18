import 'package:parqr/domain/entities/payment.dart';
import 'package:parqr/domain/repositories/payment_repository.dart';

class ProcessPaymentUseCase {
  final IPaymentRepository repository;

  ProcessPaymentUseCase({required this.repository});

  /// Processes the payment by initiating a payment intent (CASH or QRIS)
  Future<Payment> initiatePayment({
    required String sessionId,
    required double amount,
    required String paymentMethod,
  }) async {
    return await repository.createPayment(sessionId, amount, paymentMethod);
  }

  /// Verifies a cash payment (usually triggered by an Operator)
  Future<bool> verifyCashPayment({
    required String paymentId,
    required String operatorId,
  }) async {
    return await repository.verifyCashPayment(paymentId, operatorId);
  }

  /// Checks the status of a payment (useful for polling QRIS status)
  /// Returns true if PAID, otherwise false.
  Future<bool> checkPaymentVerified(String paymentId) async {
    final payment = await repository.getPaymentStatus(paymentId);
    return payment.status == 'PAID';
  }

  /// Retrieves the exit QR after a payment is verified
  Future<String> getExitQr(String paymentId) async {
    final isVerified = await checkPaymentVerified(paymentId);
    if (!isVerified) {
      throw Exception('Payment not verified yet.');
    }
    return await repository.generateExitQr(paymentId);
  }
}
