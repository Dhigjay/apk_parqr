import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplayCard extends StatelessWidget {
  const QrDisplayCard({
    super.key,
    required this.data,
    this.title,
    this.subtitle,
    this.size = 220,
  });

  final String data;
  final String? title;
  final String? subtitle;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.08),
            blurRadius: 28,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          if (title != null) ...[
            Text(title!, style: AppTextStyles.h3, textAlign: TextAlign.center),
            const SizedBox(height: 6),
          ],
          if (subtitle != null) ...[
            Text(subtitle!,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: QrImageView(
              data: data,
              size: size,
              backgroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
