import 'package:parqr/domain/entities/payment.dart';
import 'package:parqr/domain/repositories/payment_repository.dart';
import 'package:parqr/data/datasources/remote/payment_remote_ds.dart';

class PaymentRepositoryImpl implements IPaymentRepository {
  final IPaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Payment> createPayment(String sessionId, double amount, String paymentMethod) async {
    return await remoteDataSource.createPayment(sessionId, amount, paymentMethod);
  }

  @override
  Future<Payment> getPaymentStatus(String paymentId) async {
    return await remoteDataSource.getPaymentStatus(paymentId);
  }

  @override
  Future<bool> verifyCashPayment(String paymentId, String operatorId) async {
    return await remoteDataSource.verifyCashPayment(paymentId, operatorId);
  }

  @override
  Future<String> generateExitQr(String paymentId) async {
    return await remoteDataSource.generateExitQr(paymentId);
  }
}
