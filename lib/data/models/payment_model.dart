import 'package:parqr/domain/entities/payment.dart';

class PaymentModel extends Payment {
  PaymentModel({
    required super.id,
    required super.sessionId,
    required super.amount,
    required super.paymentMethod,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.midtransTransactionId,
    super.qrisUrl,
    super.vaNumber,
    super.bankName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      sessionId: json['parking_session_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['method'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      midtransTransactionId: json['midtrans_transaction_id'] as String?,
      qrisUrl: json['qris_url'] as String?,
      vaNumber: json['va_number'] as String?,
      bankName: json['bank'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parking_session_id': sessionId,
      'amount': amount,
      'method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'midtrans_transaction_id': midtransTransactionId,
      'qris_url': qrisUrl,
      'va_number': vaNumber,
      'bank': bankName,
    };
  }
}
