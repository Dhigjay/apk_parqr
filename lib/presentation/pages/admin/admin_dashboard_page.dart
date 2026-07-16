import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/domain/repositories/i_admin_repository.dart';
import 'package:parqr/injection/injection_container.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isLoading = true;
  String? _errorMessage;
  int _pendingReviews = 0;
  int _totalOperators = 0;
  int _totalParkingLots = 0;
  int _activeSessionsToday = 0;
  double _totalRevenueToday = 0.0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adminRepository = sl<IAdminRepository>();
      final stats = await adminRepository.getGlobalStats();
      final registrations = await adminRepository.getPendingRegistrations();

      setState(() {
        _totalOperators = stats.totalOperators;
        _totalParkingLots = stats.totalParkingLots;
        _activeSessionsToday = stats.activeSessionsToday;
        _totalRevenueToday = stats.totalRevenueToday;
        _pendingReviews = registrations
            .where((item) => item.status.toLowerCase() == 'pending')
            .length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data admin: $e';
      });
    }
  }

  String _formatCurrency(double value) {
    final amount = value.toInt().toString();
    final result = amount.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp$result';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            onPressed: () {
              context.go(RouteNames.login);
            },
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  if (_errorMessage != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.bodySecondary,
                      ),
                    ),
                  ],
                  Text(
                    'Statistik Global',
                    style:
                        AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Operator',
                          value: '$_totalOperators',
                          icon: Icons.people_alt_rounded,
                          color: AppColors.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Pending Review',
                          value: '$_pendingReviews',
                          icon: Icons.rate_review_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: 'Total Pendapatan Sistem Hari Ini',
                    value: _formatCurrency(_totalRevenueToday),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Navigasi Cepat',
                    style:
                        AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
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
                        child: const Icon(Icons.playlist_add_check_rounded,
                            color: AppColors.warning),
                      ),
                      title: Text(
                        'Daftar Pengajuan Operator',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Tinjau pendaftaran lahan parkir baru',
                        style: AppTextStyles.caption,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Log Aktivitas Sistem',
                    style:
                        AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _auditLogTile(
                    'Sesi aktif hari ini: $_activeSessionsToday',
                    'Dari database parkir aktif',
                    Icons.play_circle_outline_rounded,
                    AppColors.accentBlue,
                  ),
                  _auditLogTile(
                    'Pengajuan operator menunggu review: $_pendingReviews',
                    'Berbasis tabel operator_registrations',
                    Icons.pending_actions_rounded,
                    AppColors.warning,
                  ),
                  _auditLogTile(
                    'Lahan parkir terdaftar: $_totalParkingLots',
                    'Berbasis data parking_lots',
                    Icons.local_parking_rounded,
                    AppColors.success,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _auditLogTile(
      String message, String time, IconData icon, Color iconColor) {
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
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(time, style: AppTextStyles.caption),
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
                style:
                    AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500),
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
