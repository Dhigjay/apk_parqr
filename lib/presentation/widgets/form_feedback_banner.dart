import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_colors.dart';
import 'package:parqr/core/constants/app_text_style.dart';

enum FormFeedbackType { error, success }

class FormFeedbackBanner extends StatelessWidget {
  const FormFeedbackBanner({
    super.key,
    required this.message,
    required this.type,
  });

  final String message;
  final FormFeedbackType type;

  @override
  Widget build(BuildContext context) {
    final isSuccess = type == FormFeedbackType.success;
    final color = isSuccess ? AppColors.success : AppColors.error;
    final icon = isSuccess
        ? Icons.check_circle_outline_rounded
        : Icons.error_outline_rounded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
