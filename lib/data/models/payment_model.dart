import 'package:parqr/domain/entities/payment.dart';

class PaymentModel extends Payment {
  PaymentModel({
    required super.id,
    required super.sessionId,
    required super.amount,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
    super.midtransTransactionId,
    super.qrisUrl,
    super.vaNumber,
    super.bankName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,           // ← was 'parking_session_id'
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['method'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      midtransTransactionId: json['midtrans_transaction_id'] as String?,
      qrisUrl: json['qris_url'] as String?,
      vaNumber: json['va_number'] as String?,
      bankName: json['bank'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,                           // ← was 'parking_session_id'
      'amount': amount,
      'method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'midtrans_transaction_id': midtransTransactionId,
      'qris_url': qrisUrl,
      'va_number': vaNumber,
      'bank': bankName,
    };
  }
}
