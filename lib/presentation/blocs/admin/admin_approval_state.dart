import 'package:equatable/equatable.dart';

/// Single operator registration entry shown in the approval list
class OperatorRegistrationEntry extends Equatable {
  final String id;
  final String businessName;
  final String ownerName;
  final String address;
  final String submittedAt;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? rejectionReason;

  const OperatorRegistrationEntry({
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.address,
    required this.submittedAt,
    required this.status,
    this.rejectionReason,
  });

  @override
  List<Object?> get props => [id, businessName, ownerName, status];
}

abstract class AdminApprovalState extends Equatable {
  const AdminApprovalState();

  @override
  List<Object?> get props => [];
}

class AdminApprovalInitial extends AdminApprovalState {}

class AdminApprovalLoading extends AdminApprovalState {}

class AdminApprovalLoaded extends AdminApprovalState {
  final List<OperatorRegistrationEntry> registrations;

  const AdminApprovalLoaded({required this.registrations});

  @override
  List<Object?> get props => [registrations];
}

class AdminApprovalError extends AdminApprovalState {
  final String message;

  const AdminApprovalError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminApproveSuccess extends AdminApprovalState {
  final String registrationId;

  const AdminApproveSuccess(this.registrationId);

  @override
  List<Object?> get props => [registrationId];
}

class AdminRejectSuccess extends AdminApprovalState {
  final String registrationId;

  const AdminRejectSuccess(this.registrationId);

  @override
  List<Object?> get props => [registrationId];
}
