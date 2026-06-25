import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            onPressed: () {
              // Simulate logout to login screen
              context.go(RouteNames.login);
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Statistik Global',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Operator',
                    value: '18',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.accentBlue,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Pending Review',
                    value: '2',
                    icon: Icons.rate_review_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const _StatCard(
              title: 'Total Pendapatan Sistem Hari Ini',
              value: 'Rp4.850.000',
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.success,
            ),
            const SizedBox(height: 28),
            Text(
              'Navigasi Cepat',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                onTap: () => context.push(RouteNames.approvalList),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.playlist_add_check_rounded, color: AppColors.warning),
                ),
                title: Text(
                  'Daftar Pengajuan Operator',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Tinjau pendaftaran lahan parkir baru',
                  style: AppTextStyles.caption,
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Log Aktivitas Sistem (Realtime)',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            _auditLogTile('Operator "Budi Santoso" disetujui.', '10 menit yang lalu', Icons.check_circle_rounded, AppColors.success),
            _auditLogTile('Pengajuan baru "Lahan Parkir Sejahtera".', '1 jam yang lalu', Icons.add_circle_rounded, AppColors.accentBlue),
            _auditLogTile('Operator "Ahmad" ditolak: Foto tidak valid.', '3 jam yang lalu', Icons.cancel_rounded, AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _auditLogTile(String message, String time, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text(
                title,
                style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
