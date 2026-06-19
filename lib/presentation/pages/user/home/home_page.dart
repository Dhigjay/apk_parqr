import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_strings.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/presentation/widgets/app_bottom_nav.dart';
import 'package:parqr/presentation/widgets/empty_state_widget.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(AppStrings.tagline, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Cari parkir, pesan slot, dan gunakan QR untuk masuk-keluar area parkir.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: AppColors.accentBlue),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      Text(AppStrings.registerLot, style: AppTextStyles.body),
                ),
                const StatusBadge(label: 'Soon', type: StatusBadgeType.pending),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const EmptyStateWidget(
            title: 'Belum ada data parkir',
            message:
                'Daftar parkir terdekat akan muncul di sini setelah modul pencarian siap.',
            icon: Icons.local_parking_rounded,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (_) {},
      ),
    );
  }
}
