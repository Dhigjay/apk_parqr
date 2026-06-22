import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/core/utils/qr_validator.dart';

String _buildQr({
  String sessionId = 'ses-001',
  String type = 'entry',
  DateTime? issuedAt,
  DateTime? expiresAt,
}) {
  final now = DateTime.now();
  return jsonEncode({
    'session_id': sessionId,
    'type': type,
    'issued_at': (issuedAt ?? now.subtract(const Duration(minutes: 5))).toIso8601String(),
    'expires_at': (expiresAt ?? now.add(const Duration(hours: 23))).toIso8601String(),
  });
}

void main() {
  group('QrValidator', () {
    test('returns success for a valid entry QR', () {
      final raw = _buildQr(type: 'entry');
      final result = QrValidator.validate(raw, expectedType: 'entry');

      expect(result.isValid, isTrue);
      expect(result.payload, isNotNull);
      expect(result.payload!.type, 'entry');
    });

    test('returns success for a valid exit QR', () {
      final raw = _buildQr(type: 'exit');
      final result = QrValidator.validate(raw, expectedType: 'exit');

      expect(result.isValid, isTrue);
      expect(result.payload!.type, 'exit');
    });

    test('returns error for wrong QR type (entry vs exit)', () {
      final raw = _buildQr(type: 'exit');
      final result = QrValidator.validate(raw, expectedType: 'entry');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Tipe QR tidak sesuai'));
    });

    test('returns error for expired QR', () {
      final raw = _buildQr(
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      final result = QrValidator.validate(raw, expectedType: 'entry');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('kedaluwarsa'));
    });

    test('returns error for invalid JSON', () {
      final result = QrValidator.validate('NOT_JSON', expectedType: 'entry');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Bukan JSON'));
    });

    test('returns error for missing required fields', () {
      final raw = jsonEncode({'session_id': 'ses-001'});
      final result = QrValidator.validate(raw, expectedType: 'entry');

      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('tidak lengkap'));
    });
  });
}
