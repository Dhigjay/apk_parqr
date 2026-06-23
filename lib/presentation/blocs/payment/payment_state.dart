import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentProcessing extends PaymentState {
  final String method; // 'Cash' or 'QRIS'
  
  const PaymentProcessing({required this.method});

  @override
  List<Object?> get props => [method];
}

class PaymentAwaitingVerification extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String exitQrPayload;

  const PaymentSuccess({required this.exitQrPayload});

  @override
  List<Object?> get props => [exitQrPayload];
}

class PaymentFailed extends PaymentState {
  final String message;

  const PaymentFailed(this.message);

  @override
  List<Object?> get props => [message];
}
