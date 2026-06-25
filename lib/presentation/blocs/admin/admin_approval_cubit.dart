import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parqr/domain/repositories/i_admin_repository.dart';
import 'admin_approval_state.dart';

class AdminApprovalCubit extends Cubit<AdminApprovalState> {
  final IAdminRepository adminRepository;

  AdminApprovalCubit({required this.adminRepository}) : super(AdminApprovalInitial());

  /// Fetch all operator registrations (pending, approved, rejected)
  Future<void> loadRegistrations() async {
    emit(AdminApprovalLoading());
    try {
      final registrations = await adminRepository.getPendingRegistrations();
      
      final entries = registrations.map((r) => OperatorRegistrationEntry(
        id: r.id,
        businessName: r.businessName,
        ownerName: 'Pemilik Lahan', // look up applicant name or default
        address: r.address,
        submittedAt: r.createdAt.toIso8601String(),
        status: r.status,
        rejectionReason: r.rejectReason,
      )).toList();

      emit(AdminApprovalLoaded(registrations: entries));
    } catch (e) {
      emit(AdminApprovalError('Gagal memuat daftar pengajuan: ${e.toString()}'));
    }
  }

  /// Approve an operator registration
  Future<void> approveOperator(String registrationId) async {
    try {
      emit(AdminApprovalLoading());
      await adminRepository.approveOperator(registrationId);
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
      await adminRepository.rejectOperator(registrationId, reason);
      emit(AdminRejectSuccess(registrationId));
      // Reload the list after action
      await loadRegistrations();
    } catch (e) {
      emit(AdminApprovalError('Gagal menolak operator: ${e.toString()}'));
    }
  }
}
