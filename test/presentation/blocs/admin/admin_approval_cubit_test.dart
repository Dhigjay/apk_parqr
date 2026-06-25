import 'package:flutter_test/flutter_test.dart';
import 'package:parqr/domain/entities/admin_stats_entity.dart';
import 'package:parqr/domain/entities/operator_registration_entity.dart';
import 'package:parqr/domain/repositories/i_admin_repository.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_cubit.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_state.dart';

class _FakeAdminRepository implements IAdminRepository {
  final List<OperatorRegistrationEntity> _registrations = [
    OperatorRegistrationEntity(
      id: 'reg-001',
      applicantUserId: 'user-1',
      businessName: 'Parkir Sejahtera',
      address: 'Jl. Sudirman No. 10, Jakarta',
      floors: 1,
      capacityPerFloor: const {},
      totalCapacity: 50,
      pricePerHour: 5000,
      status: 'pending',
      createdAt: DateTime.parse('2026-06-15T10:00:00Z'),
      updatedAt: DateTime.parse('2026-06-15T10:00:00Z'),
    ),
  ];

  @override
  Future<List<OperatorRegistrationEntity>> getPendingRegistrations() async {
    return _registrations;
  }

  @override
  Future<OperatorRegistrationEntity> getRegistrationDetail(String id) async {
    return _registrations.firstWhere((r) => r.id == id);
  }

  @override
  Future<void> approveOperator(String id) async {
    final idx = _registrations.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final old = _registrations[idx];
      _registrations[idx] = OperatorRegistrationEntity(
        id: old.id,
        applicantUserId: old.applicantUserId,
        businessName: old.businessName,
        address: old.address,
        floors: old.floors,
        capacityPerFloor: old.capacityPerFloor,
        totalCapacity: old.totalCapacity,
        pricePerHour: old.pricePerHour,
        status: 'approved',
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> rejectOperator(String id, String reason) async {
    final idx = _registrations.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final old = _registrations[idx];
      _registrations[idx] = OperatorRegistrationEntity(
        id: old.id,
        applicantUserId: old.applicantUserId,
        businessName: old.businessName,
        address: old.address,
        floors: old.floors,
        capacityPerFloor: old.capacityPerFloor,
        totalCapacity: old.totalCapacity,
        pricePerHour: old.pricePerHour,
        status: 'rejected',
        rejectReason: reason,
        createdAt: old.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<AdminStatsEntity> getGlobalStats() async {
    throw UnimplementedError();
  }
}

void main() {
  late AdminApprovalCubit cubit;

  setUp(() {
    cubit = AdminApprovalCubit(adminRepository: _FakeAdminRepository());
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
