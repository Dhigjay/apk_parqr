import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/presentation/blocs/operator/operator_dashboard_cubit.dart';
import 'package:parqr/presentation/blocs/operator/operator_dashboard_state.dart';

String _validEntryQr() {
  final now = DateTime.now();
  return jsonEncode({
    'session_id': 'ses-test-001',
    'type': 'entry',
    'issued_at': now.subtract(const Duration(minutes: 1)).toIso8601String(),
    'expires_at': now.add(const Duration(hours: 23)).toIso8601String(),
  });
}

String _expiredQr() {
  final now = DateTime.now();
  return jsonEncode({
    'session_id': 'ses-test-002',
    'type': 'entry',
    'issued_at': now.subtract(const Duration(hours: 25)).toIso8601String(),
    'expires_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
  });
}

void main() {
  late OperatorDashboardCubit cubit;

  setUp(() {
    cubit = OperatorDashboardCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('OperatorDashboardCubit', () {
    test('initial state is OperatorDashboardInitial', () {
      expect(cubit.state, isA<OperatorDashboardInitial>());
    });

    test('loadDashboard emits Loading then Loaded', () async {
      final expectedStates = [
        isA<OperatorDashboardLoading>(),
        isA<OperatorDashboardLoaded>(),
      ];
      expectLater(cubit.stream, emitsInOrder(expectedStates));
      cubit.loadDashboard();
    });

    test('loadDashboard Loaded state contains stats and vehicles', () async {
      await cubit.loadDashboard();
      final state = cubit.state as OperatorDashboardLoaded;
      expect(state.stats, isNotNull);
      expect(state.activeVehicles, isNotEmpty);
    });

    test('processScannedQr with valid entry QR emits Success then reloads', () async {
      final expectedStates = [
        isA<OperatorQrScanSuccess>(),
        isA<OperatorDashboardLoading>(),
        isA<OperatorDashboardLoaded>(),
      ];
      expectLater(cubit.stream, emitsInOrder(expectedStates));
      cubit.processScannedQr(_validEntryQr(), expectedType: 'entry');
    });

    test('processScannedQr with expired QR emits ScanError', () async {
      expectLater(cubit.stream, emits(isA<OperatorQrScanError>()));
      cubit.processScannedQr(_expiredQr(), expectedType: 'entry');
    });

    test('processScannedQr with wrong type emits ScanError', () async {
      expectLater(cubit.stream, emits(isA<OperatorQrScanError>()));
      // Send entry QR but expect exit
      cubit.processScannedQr(_validEntryQr(), expectedType: 'exit');
    });

    test('verifyCashPayment emits CashVerified then reloads dashboard', () async {
      final expectedStates = [
        isA<OperatorCashVerified>(),
        isA<OperatorDashboardLoading>(),
        isA<OperatorDashboardLoaded>(),
      ];
      expectLater(cubit.stream, emitsInOrder(expectedStates));
      cubit.verifyCashPayment('session-001');
    });
  });
}
