class NotificationSettingsEntity {
  final String userId;
  final bool bookingSuccess;
  final bool bookingCancelled;
  final bool bookingExpiring;
  final bool qrCreated;
  final bool vehicleCheckin;
  final bool vehicleCheckout;
  final bool parkingDurationReminder;
  final bool paymentSuccess;
  final bool paymentFailed;
  final bool refund;
  final bool passwordChanged;
  final bool newDeviceLogin;
  final bool profileUpdated;
  final bool operatorApproved;
  final bool operatorRejected;
  final bool promoNew;
  final bool parkingDiscount;
  final bool maintenance;
  final bool appUpdate;
  final bool securityInfo;

  NotificationSettingsEntity({
    required this.userId,
    this.bookingSuccess = true,
    this.bookingCancelled = true,
    this.bookingExpiring = true,
    this.qrCreated = true,
    this.vehicleCheckin = true,
    this.vehicleCheckout = true,
    this.parkingDurationReminder = true,
    this.paymentSuccess = true,
    this.paymentFailed = true,
    this.refund = true,
    this.passwordChanged = true,
    this.newDeviceLogin = true,
    this.profileUpdated = true,
    this.operatorApproved = true,
    this.operatorRejected = true,
    this.promoNew = true,
    this.parkingDiscount = true,
    this.maintenance = true,
    this.appUpdate = true,
    this.securityInfo = true,
  });

  factory NotificationSettingsEntity.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsEntity(
      userId: json['user_id'] as String,
      bookingSuccess: json['booking_success'] as bool? ?? true,
      bookingCancelled: json['booking_cancelled'] as bool? ?? true,
      bookingExpiring: json['booking_expiring'] as bool? ?? true,
      qrCreated: json['qr_created'] as bool? ?? true,
      vehicleCheckin: json['vehicle_checkin'] as bool? ?? true,
      vehicleCheckout: json['vehicle_checkout'] as bool? ?? true,
      parkingDurationReminder: json['parking_duration_reminder'] as bool? ?? true,
      paymentSuccess: json['payment_success'] as bool? ?? true,
      paymentFailed: json['payment_failed'] as bool? ?? true,
      refund: json['refund'] as bool? ?? true,
      passwordChanged: json['password_changed'] as bool? ?? true,
      newDeviceLogin: json['new_device_login'] as bool? ?? true,
      profileUpdated: json['profile_updated'] as bool? ?? true,
      operatorApproved: json['operator_approved'] as bool? ?? true,
      operatorRejected: json['operator_rejected'] as bool? ?? true,
      promoNew: json['promo_new'] as bool? ?? true,
      parkingDiscount: json['parking_discount'] as bool? ?? true,
      maintenance: json['maintenance'] as bool? ?? true,
      appUpdate: json['app_update'] as bool? ?? true,
      securityInfo: json['security_info'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'booking_success': bookingSuccess,
      'booking_cancelled': bookingCancelled,
      'booking_expiring': bookingExpiring,
      'qr_created': qrCreated,
      'vehicle_checkin': vehicleCheckin,
      'vehicle_checkout': vehicleCheckout,
      'parking_duration_reminder': parkingDurationReminder,
      'payment_success': paymentSuccess,
      'payment_failed': paymentFailed,
      'refund': refund,
      'password_changed': passwordChanged,
      'new_device_login': newDeviceLogin,
      'profile_updated': profileUpdated,
      'operator_approved': operatorApproved,
      'operator_rejected': operatorRejected,
      'promo_new': promoNew,
      'parking_discount': parkingDiscount,
      'maintenance': maintenance,
      'app_update': appUpdate,
      'security_info': securityInfo,
    };
  }
}
