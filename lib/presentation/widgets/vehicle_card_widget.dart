import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:parqr/presentation/widgets/status_badge.dart';

class VehicleCardWidget extends StatelessWidget {
  const VehicleCardWidget({
    super.key,
    required this.plateNumber,
    required this.vehicleName,
    this.typeLabel,
    this.statusLabel,
    this.onTap,
  });

  final String plateNumber;
  final String vehicleName;
  final String? typeLabel;
  final String? statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car_filled_rounded,
                    color: AppColors.accentBlue),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plateNumber, style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      [vehicleName, typeLabel].whereType<String>().join(' - '),
                      style: AppTextStyles.bodySecondary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (statusLabel != null)
                StatusBadge(label: statusLabel!, type: StatusBadgeType.active),
            ],
          ),
        ),
      ),
    );
  }
}
