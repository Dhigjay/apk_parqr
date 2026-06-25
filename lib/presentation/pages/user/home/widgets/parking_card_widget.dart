import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class ParkingCardWidget extends StatelessWidget {
  const ParkingCardWidget({
    super.key,
    required this.name,
    required this.address,
    required this.distance,
    required this.pricePerHour,
    required this.availableSlots,
    required this.totalSlots,
    this.onTap,
  });

  final String name;
  final String address;
  final String distance;
  final String pricePerHour;
  final int availableSlots;
  final int totalSlots;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final availabilityType =
        availableSlots > 8 ? StatusBadgeType.active : StatusBadgeType.pending;

    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_parking_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: AppTextStyles.h3),
                        const SizedBox(height: 6),
                        Text(
                          address,
                          style: AppTextStyles.bodySecondary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.near_me_outlined,
                    label: distance,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.payments_outlined,
                    label: pricePerHour,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$availableSlots dari $totalSlots slot tersedia',
                      style: AppTextStyles.caption,
                    ),
                  ),
                  StatusBadge(
                    label: availableSlots > 0 ? 'Tersedia' : 'Penuh',
                    type: availableSlots > 0
                        ? availabilityType
                        : StatusBadgeType.expired,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParkingCardSkeleton extends StatelessWidget {
  const ParkingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SkeletonBox(width: 54, height: 54, radius: 14),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 160, height: 16),
                    SizedBox(height: 10),
                    _SkeletonBox(width: double.infinity, height: 12),
                    SizedBox(height: 8),
                    _SkeletonBox(width: 210, height: 12),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _SkeletonBox(width: 230, height: 34, radius: 999),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accentBlue),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
