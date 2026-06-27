import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/core/router/route_names.dart';
import 'package:parqr/presentation/blocs/profile/profile_cubit.dart';
import 'package:parqr/presentation/widgets/app_bottom_nav.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _onLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar Akun',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun ini?',
          style: TextStyle(color: Color(0xFF8B949E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(_).pop(false),
            child: const Text('Batal',
                style: TextStyle(color: Color(0xFF8B949E))),
          ),
          TextButton(
            onPressed: () => Navigator.of(_).pop(true),
            child: const Text('Keluar',
                style: TextStyle(
                    color: Color(0xFFFF4D4D), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.go(RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // ── Avatar & Name ────────────────────────────────────
          _ProfileHeader(),
          const SizedBox(height: 28),

          // ── Kendaraan ────────────────────────────────────────
          const _SectionLabel(label: 'Kendaraan Terdaftar'),
          const SizedBox(height: 12),
          _VehicleCard(
            plate: 'B 1234 QR',
            vehicleName: 'Honda Vario 125',
            type: 'Motor',
            onEdit: () {},
          ),
          const SizedBox(height: 8),
          _AddVehicleButton(onTap: () {}),
          const SizedBox(height: 28),

          // ── Pengaturan Akun ──────────────────────────────────
          const _SectionLabel(label: 'Pengaturan Akun'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profil',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            label: 'Ubah Kata Sandi',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notifikasi',
            onTap: () {},
          ),
          const SizedBox(height: 28),

          // ── Lainnya ──────────────────────────────────────────
          const _SectionLabel(label: 'Lainnya'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Bantuan & FAQ',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.policy_outlined,
            label: 'Kebijakan Privasi',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'Tentang Aplikasi',
            trailing: Text(
              'v1.0.0',
              style: AppTextStyles.caption,
            ),
            onTap: () {},
          ),
          const SizedBox(height: 28),

          // ── Tombol Logout ────────────────────────────────────
          _LogoutButton(onTap: () => _onLogout(context)),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go(RouteNames.home);
          if (index == 1) context.go(RouteNames.history);
        },
      ),
    );
  }
}

// ── Sub-Widgets ──────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar circle with gradient
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Center(
              child: Text(
                'AF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Afif Hidayatullah',
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'afif@example.com',
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Pengguna',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: AppColors.textSecondary, size: 20),
            onPressed: () {},
            tooltip: 'Edit Profil',
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.plate,
    required this.vehicleName,
    required this.type,
    required this.onEdit,
  });

  final String plate;
  final String vehicleName;
  final String type;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_bike_rounded,
              color: AppColors.accentBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plate,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$vehicleName • $type',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _AddVehicleButton extends StatelessWidget {
  const _AddVehicleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 8),
            Text('Tambah Kendaraan', style: AppTextStyles.bodySecondary),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(label, style: AppTextStyles.body),
                ),
                trailing ??
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Keluar Akun'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
