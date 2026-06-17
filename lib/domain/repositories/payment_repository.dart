import 'package:parqr/domain/entities/payment.dart';

abstract class IPaymentRepository {
  Future<Payment> createPayment(String sessionId, double amount, String paymentMethod);
  Future<Payment> getPaymentStatus(String paymentId);
  Future<bool> verifyCashPayment(String paymentId, String operatorId);
  Future<String> generateExitQr(String paymentId);
}
