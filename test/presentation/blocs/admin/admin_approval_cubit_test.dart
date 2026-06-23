import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_cubit.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_state.dart';

void main() {
  late AdminApprovalCubit cubit;

  setUp(() {
    cubit = AdminApprovalCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('AdminApprovalCubit', () {
    test('initial state is AdminApprovalInitial', () {
      expect(cubit.state, isA<AdminApprovalInitial>());
    });

    test('loadRegistrations emits Loading then Loaded', () async {
      final expectedStates = [
        isA<AdminApprovalLoading>(),
        isA<AdminApprovalLoaded>(),
      ];
      expectLater(cubit.stream, emitsInOrder(expectedStates));
      cubit.loadRegistrations();
    });

    test('loadRegistrations Loaded state contains registrations', () async {
      await cubit.loadRegistrations();
      final state = cubit.state as AdminApprovalLoaded;
      expect(state.registrations, isNotEmpty);
    });

    test('approveOperator emits Loading, ApproveSuccess, Loading, Loaded', () async {
      final expectedStates = [
        isA<AdminApprovalLoading>(),
        isA<AdminApproveSuccess>(),
        isA<AdminApprovalLoading>(),
        isA<AdminApprovalLoaded>(),
      ];
      expectLater(cubit.stream, emitsInOrder(expectedStates));
      cubit.approveOperator('reg-001');
    });

    test('rejectOperator with valid reason emits Loading, RejectSuccess, Loading, Loaded', () async {
      final expectedStates = [
        isA<AdminApprovalLoading>(),
        isA<AdminRejectSuccess>(),
        isA<AdminApprovalLoading>(),
        isA<AdminApprovalLoaded>(),
      ];
      expectLater(cubit.stream, emitsInOrder(expectedStates));
      cubit.rejectOperator('reg-001', reason: 'Dokumen tidak lengkap');
    });

    test('rejectOperator with empty reason emits AdminApprovalError', () async {
      expectLater(cubit.stream, emits(isA<AdminApprovalError>()));
      cubit.rejectOperator('reg-001', reason: '');
    });

    test('rejectOperator with whitespace-only reason emits AdminApprovalError', () async {
      expectLater(cubit.stream, emits(isA<AdminApprovalError>()));
      cubit.rejectOperator('reg-001', reason: '   ');
    });
  });
}
