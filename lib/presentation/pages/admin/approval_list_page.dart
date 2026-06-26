import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_cubit.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_state.dart';
import 'package:parqr/presentation/widgets/empty_state_widget.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';
import 'package:intl/intl.dart';

class ApprovalListPage extends StatefulWidget {
  const ApprovalListPage({super.key});

  @override
  State<ApprovalListPage> createState() => _ApprovalListPageState();
}

class _ApprovalListPageState extends State<ApprovalListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<AdminApprovalCubit>().loadRegistrations();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Operator'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentBlue,
          labelColor: AppColors.accentBlue,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Disetujui'),
            Tab(text: 'Ditolak'),
          ],
        ),
      ),
      body: BlocBuilder<AdminApprovalCubit, AdminApprovalState>(
        builder: (context, state) {
          if (state is AdminApprovalLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AdminApprovalError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyStateWidget(
                  title: 'Gagal Memuat Data',
                  message: state.message,
                  icon: Icons.error_outline_rounded,
                  actionLabel: 'Coba Lagi',
                  onAction: () => context.read<AdminApprovalCubit>().loadRegistrations(),
                ),
              ),
            );
          } else if (state is AdminApprovalLoaded) {
            final pendingList = state.registrations.where((r) => r.status == 'pending').toList();
            final approvedList = state.registrations.where((r) => r.status == 'approved').toList();
            final rejectedList = state.registrations.where((r) => r.status == 'rejected').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildListView(pendingList, 'Tidak ada pengajuan tertunda.', StatusBadgeType.warning),
                _buildListView(approvedList, 'Tidak ada pengajuan disetujui.', StatusBadgeType.active),
                _buildListView(rejectedList, 'Tidak ada pengajuan ditolak.', StatusBadgeType.expired),
              ],
            );
          }
          return const Center(child: Text('Memulai...'));
        },
      ),
    );
  }

  Widget _buildListView(
    List<OperatorRegistrationEntry> list,
    String emptyMessage,
    StatusBadgeType statusType,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyStateWidget(
            title: 'Daftar Kosong',
            message: emptyMessage,
            icon: Icons.inbox_rounded,
          ),
        ),
      );
    }

    final dateFormatter = DateFormat('dd MMM yyyy, HH:mm');

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final registration = list[index];
        final DateTime parsedDate = DateTime.tryParse(registration.submittedAt) ?? DateTime.now();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    registration.businessName,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                StatusBadge(
                  label: registration.status.toUpperCase(),
                  type: statusType,
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  'Pemilik: ${registration.ownerName}',
                  style: AppTextStyles.caption,
                ),
                Text(
                  'Diajukan: ${dateFormatter.format(parsedDate)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
            onTap: () {
              context.push(
                RouteNames.approvalDetail,
                extra: {
                  'id': registration.id,
                  'businessName': registration.businessName,
                  'ownerName': registration.ownerName,
                  'address': registration.address,
                  'status': registration.status,
                },
              );
            },
          ),
        );
      },
    );
  }
}
