import 'dart:convert';

class QrPayload {
  final String sessionId;
  final String type;
  final DateTime issuedAt;
  final DateTime expiresAt;

  QrPayload({
    required this.sessionId,
    required this.type,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory QrPayload.fromJson(Map<String, dynamic> json) {
    return QrPayload(
      sessionId: json['session_id'],
      type: json['type'],
      issuedAt: DateTime.parse(json['issued_at']),
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}

class QrValidationResult {
  final bool isValid;
  final String? errorMessage;
  final QrPayload? payload;

  QrValidationResult._({required this.isValid, this.errorMessage, this.payload});

  factory QrValidationResult.success(QrPayload payload) {
    return QrValidationResult._(isValid: true, payload: payload);
  }

  factory QrValidationResult.error(String message) {
    return QrValidationResult._(isValid: false, errorMessage: message);
  }
}

class QrValidator {
  /// Validates a raw QR code string.
  /// Checks if it's a valid JSON, contains required fields, checks type, and verifies expiration.
  static QrValidationResult validate(String rawData, {required String expectedType}) {
    try {
      final decoded = jsonDecode(rawData);
      
      if (!decoded.containsKey('session_id') || 
          !decoded.containsKey('type') || 
          !decoded.containsKey('issued_at') || 
          !decoded.containsKey('expires_at')) {
        return QrValidationResult.error('Format QR tidak valid: Atribut tidak lengkap');
      }

      final payload = QrPayload.fromJson(decoded);

      if (payload.type != expectedType) {
        return QrValidationResult.error('Tipe QR tidak sesuai (Diharapkan: $expectedType, Diterima: ${payload.type})');
      }

      final now = DateTime.now();
      if (now.isAfter(payload.expiresAt)) {
        return QrValidationResult.error('QR sudah kedaluwarsa');
      }

      return QrValidationResult.success(payload);

    } catch (e) {
      return QrValidationResult.error('Format QR tidak valid: Bukan JSON yang valid');
    }
  }
}
