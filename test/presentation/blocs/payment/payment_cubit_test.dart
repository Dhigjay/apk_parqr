import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/presentation/blocs/payment/payment_cubit.dart';
import 'package:parqr/presentation/blocs/payment/payment_state.dart';

void main() {
  late PaymentCubit paymentCubit;

  setUp(() {
    paymentCubit = PaymentCubit();
  });

  tearDown(() {
    paymentCubit.close();
  });

  group('PaymentCubit', () {
    test('initial state is PaymentInitial', () {
      expect(paymentCubit.state, isA<PaymentInitial>());
    });

    test('processCashPayment emits Processing, AwaitingVerification, then Success', () async {
      final expectedStates = [
        isA<PaymentProcessing>(),
        isA<PaymentAwaitingVerification>(),
        isA<PaymentSuccess>(),
      ];

      expectLater(paymentCubit.stream, emitsInOrder(expectedStates));

      paymentCubit.processCashPayment();
    });

    test('processQrisPayment emits Processing then Success', () async {
      final expectedStates = [
        isA<PaymentProcessing>(),
        isA<PaymentSuccess>(),
      ];

      expectLater(paymentCubit.stream, emitsInOrder(expectedStates));

      paymentCubit.processQrisPayment();
    });

    test('cancelPayment reverts to PaymentInitial', () async {
      final expectedStates = [
        isA<PaymentProcessing>(),
        isA<PaymentInitial>(),
      ];

      expectLater(paymentCubit.stream, emitsInOrder(expectedStates));

      paymentCubit.processQrisPayment();
      
      // Adding a small delay to ensure Processing is emitted first
      await Future.delayed(const Duration(milliseconds: 100));
      paymentCubit.cancelPayment();
    });
  });
}
