class Payment {
  final String id;
  final String sessionId;
  final double amount;
  final String paymentMethod; // 'cash', 'qris', 'va_bca', 'va_bni', 'va_bri'
  final String status; // 'pending', 'paid', 'failed', 'expired', 'cancelled'
  final DateTime createdAt;
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
    this.midtransTransactionId,
    this.qrisUrl,
    this.vaNumber,
    this.bankName,
  });
}
