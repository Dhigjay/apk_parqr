class Payment {
  final String id;
  final String sessionId;
  final double amount;
  final String paymentMethod; // 'CASH' or 'QRIS'
  final String status; // 'PENDING', 'PAID', 'FAILED'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? midtransTransactionId;
  final String? qrisUrl;
  final String? vaNumber;
  final String? bankName;

  Payment({
    required this.id,
    required this.sessionId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.midtransTransactionId,
    this.qrisUrl,
    this.vaNumber,
    this.bankName,
  });
}
