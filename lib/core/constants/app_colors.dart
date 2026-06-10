import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color bgPrimary    = Color(0xFF0D1117);
  static const Color bgCard       = Color(0xFF161B22);
  static const Color bgElevated   = Color(0xFF1C232C);

  // Accent
  static const Color accentBlue   = Color(0xFF00C2FF);
  static const Color accentPurple = Color(0xFF7B61FF);
  static const Color success      = Color(0xFF00D68F);
  static const Color warning      = Color(0xFFFF8C42);
  static const Color error        = Color(0xFFFF4D4D);

  // Text
  static const Color textPrimary   = Color(0xFFE8EDF3);
  static const Color textSecondary = Color(0xFF8B949E);

  // Border
  static const Color border = Color(0xFF2A3441);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPurple, accentBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}