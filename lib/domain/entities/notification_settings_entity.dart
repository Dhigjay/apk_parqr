class NotificationSettingsEntity {
  final String id;
  final String userId;
  final bool bookingNotification;
  final bool paymentNotification;
  final bool parkingNotification;
  final bool promotionNotification;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NotificationSettingsEntity({
    this.id = '',
    required this.userId,
    this.bookingNotification = true,
    this.paymentNotification = true,
    this.parkingNotification = true,
    this.promotionNotification = true,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationSettingsEntity.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsEntity(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String,
      bookingNotification: json['booking_notification'] as bool? ?? true,
      paymentNotification: json['payment_notification'] as bool? ?? true,
      parkingNotification: json['parking_notification'] as bool? ?? true,
      promotionNotification: json['promotion_notification'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'booking_notification': bookingNotification,
      'payment_notification': paymentNotification,
      'parking_notification': parkingNotification,
      'promotion_notification': promotionNotification,
    };
  }
}
