import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_state.dart';

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

  void processQrisPayment() async {
    emit(const PaymentProcessing(method: 'QRIS'));
    // Simulate waiting for QRIS callback
    _pollingTimer = Timer(const Duration(seconds: 3), () {
      emit(const PaymentSuccess(exitQrPayload: 'EXIT-QR-PAYLOAD-123'));
    });
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
