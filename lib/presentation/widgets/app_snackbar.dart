import 'package:flutter/material.dart';
import 'package:parqr/core/constants/app_colors.dart';

class AppSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.red, Icons.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppColors.accentBlue, Icons.info);
  }

  static void _show(
      BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
