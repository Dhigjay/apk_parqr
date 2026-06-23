import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_approval_state.dart';

class AdminApprovalCubit extends Cubit<AdminApprovalState> {
  AdminApprovalCubit() : super(AdminApprovalInitial());

  /// Fetch all operator registrations (pending, approved, rejected)
  Future<void> loadRegistrations() async {
    emit(AdminApprovalLoading());
    try {
      // Simulated delay — replace with actual IAdminRepository call
      await Future.delayed(const Duration(milliseconds: 500));

      final registrations = [
        const OperatorRegistrationEntry(
          id: 'reg-001',
          businessName: 'Parkir Sejahtera',
          ownerName: 'Budi Santoso',
          address: 'Jl. Sudirman No. 10, Jakarta',
          submittedAt: '2026-06-15T10:00:00Z',
          status: 'pending',
        ),
        const OperatorRegistrationEntry(
          id: 'reg-002',
          businessName: 'Lahan Parkir Maju',
          ownerName: 'Siti Rahayu',
          address: 'Jl. Gatot Subroto No. 5, Bandung',
          submittedAt: '2026-06-14T08:30:00Z',
          status: 'pending',
        ),
        const OperatorRegistrationEntry(
          id: 'reg-003',
          businessName: 'Parkir Cepat',
          ownerName: 'Ahmad Fauzi',
          address: 'Jl. Diponegoro No. 22, Surabaya',
          submittedAt: '2026-06-12T14:00:00Z',
          status: 'approved',
        ),
      ];

      emit(AdminApprovalLoaded(registrations: registrations));
    } catch (e) {
      emit(AdminApprovalError('Gagal memuat daftar pengajuan: ${e.toString()}'));
    }
  }

  /// Approve an operator registration
  Future<void> approveOperator(String registrationId) async {
    try {
      emit(AdminApprovalLoading());
      // Simulated API call — replace with actual IAdminRepository.approveOperator()
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AdminApproveSuccess(registrationId));
      // Reload the list after action
      await loadRegistrations();
    } catch (e) {
      emit(AdminApprovalError('Gagal menyetujui operator: ${e.toString()}'));
    }
  }

  /// Reject an operator registration with a reason
  Future<void> rejectOperator(String registrationId, {required String reason}) async {
    if (reason.trim().isEmpty) {
      emit(const AdminApprovalError('Alasan penolakan wajib diisi'));
      return;
    }
    try {
      emit(AdminApprovalLoading());
      // Simulated API call — replace with actual IAdminRepository.rejectOperator()
      await Future.delayed(const Duration(milliseconds: 500));
      emit(AdminRejectSuccess(registrationId));
      // Reload the list after action
      await loadRegistrations();
    } catch (e) {
      emit(AdminApprovalError('Gagal menolak operator: ${e.toString()}'));
    }
  }
}
