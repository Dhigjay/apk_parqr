import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parqr/core/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );
  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary,
  );
  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textPrimary,
  );
  static TextStyle get bodySecondary => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary,
  );
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.textSecondary,
  );
  static TextStyle get button => GoogleFonts.inter(
    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
}