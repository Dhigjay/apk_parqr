import 'package:equatable/equatable.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentProcessing extends PaymentState {
  final String method;

  const PaymentProcessing({required this.method});

  @override
  List<Object?> get props => [method];
}

class PaymentAwaitingVerification extends PaymentState {}

/// State saat Snap URL berhasil didapat dan halaman Midtrans sudah dibuka
/// di browser. App menunggu webhook/realtime update status pembayaran.
class PaymentSnapOpened extends PaymentState {
  final String snapUrl;
  final String snapToken;
  final String paymentId;

  const PaymentSnapOpened({
    required this.snapUrl,
    required this.snapToken,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [snapUrl, snapToken, paymentId];
}

class PaymentQrisGenerated extends PaymentState {
  final String qrisUrl;
  final String paymentId;

  const PaymentQrisGenerated({required this.qrisUrl, required this.paymentId});

  @override
  List<Object?> get props => [qrisUrl, paymentId];
}

class PaymentVaGenerated extends PaymentState {
  final String vaNumber;
  final String bank;
  final String paymentId;

  const PaymentVaGenerated({
    required this.vaNumber,
    required this.bank,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [vaNumber, bank, paymentId];
}

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