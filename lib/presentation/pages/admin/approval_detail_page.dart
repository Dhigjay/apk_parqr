import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_cubit.dart';
import 'package:parqr/presentation/blocs/admin/admin_approval_state.dart';
import 'package:parqr/presentation/widgets/app_button.dart';
import 'package:parqr/presentation/widgets/app_text_field.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class ApprovalDetailPage extends StatefulWidget {
  const ApprovalDetailPage({
    super.key,
    required this.id,
    required this.businessName,
    required this.ownerName,
    required this.address,
    required this.status,
  });

  final String id;
  final String businessName;
  final String ownerName;
  final String address;
  final String status;

  @override
  State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  final _rejectReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Penting: pakai `dialogContext` (parameter builder), BUKAN `context`
        // dari _ApprovalDetailPageState. dialogContext ini yang benar-benar
        // berada di bawah Navigator yang dibuat oleh showDialog, sehingga
        // Navigator.pop(dialogContext) pasti menutup dialog ini secara aman,
        // tanpa mengganggu Navigator milik halaman induk.
        return Dialog(
          backgroundColor: AppColors.bgElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Alasan Penolakan',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AppTextField(
                    label: 'Tulis Alasan Penolakan',
                    controller: _rejectReasonController,
                    hintText: 'Misal: Dokumen foto lahan parkir buram/tidak valid.',
                    maxLines: 3,
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? 'Alasan penolakan wajib diisi'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final reason = _rejectReasonController.text;
                            Navigator.pop(dialogContext);
                            _reject(reason);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Kirim Penolakan', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _approve() {
    context.read<AdminApprovalCubit>().approveOperator(widget.id);
  }

  void _reject(String reason) {
    context.read<AdminApprovalCubit>().rejectOperator(widget.id, reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminApprovalCubit, AdminApprovalState>(
      listener: (context, state) {
        if (state is AdminApproveSuccess && state.registrationId == widget.id) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operator berhasil disetujui.'),
              backgroundColor: AppColors.success,
            ),
          );
          // Reload list dilakukan di sini, SETELAH listener menangkap sukses,
          // bukan otomatis di dalam cubit — supaya tidak menimpa state Success
          // sebelum listener punya kesempatan merespon.
          context.read<AdminApprovalCubit>().loadRegistrations();
          context.pop();
        } else if (state is AdminRejectSuccess && state.registrationId == widget.id) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Operator berhasil ditolak.'),
              backgroundColor: AppColors.error,
            ),
          );
          context.read<AdminApprovalCubit>().loadRegistrations();
          context.pop();
        } else if (state is AdminApprovalError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Pengajuan'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Business Header info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.businessName,
                              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          StatusBadge(
                            label: widget.status.toUpperCase(),
                            type: widget.status == 'pending'
                                ? StatusBadgeType.warning
                                : (widget.status == 'approved'
                                    ? StatusBadgeType.active
                                    : StatusBadgeType.expired),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pemilik: ${widget.ownerName}',
                        style: AppTextStyles.bodySecondary,
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.address,
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Map / Location preview
                Text(
                  'Lokasi Lahan',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_rounded, color: AppColors.accentBlue, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Peta Alamat Lokasi (Dark Mode Tiles)',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Lahan info details
                Text(
                  'Rincian Lahan',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _detailRow('Luas Lahan', '150 m²'),
                _detailRow('Jumlah Lantai', '3 Lantai'),
                _detailRow('Kapasitas Total', '80 Slot'),
                _detailRow('Tarif Per Jam', 'Rp5.000'),
                const SizedBox(height: 24),
                // Photos
                Text(
                  'Foto Lahan',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_size_select_actual_outlined, color: AppColors.accentBlue, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Foto Bukti Lahan Parkir',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Verification CTAs
                if (widget.status == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showRejectDialog,
                          icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                          label: const Text('Tolak'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          label: 'Setujui',
                          icon: Icons.check_circle_outline_rounded,
                          onPressed: _approve,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          Text(
            value,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}