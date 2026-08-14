import 'package:flutter/material.dart';

/// Bảng màu chuẩn ZenFlashCards — Dark Navy Zen Theme
/// Tuân thủ quy chuẩn Plan_UI/plan_UI-UX.md & WCAG AA Contrast
abstract class AppColors {
  // Brand & Background Colors
  static const Color bgMain = Color(0xFF0F172A);      // Navy rất tối
  static const Color bgSurface = Color(0xFF1E293B);   // Navy card & bottom bar
  static const Color primary = Color(0xFF4F46E5);     // Indigo accent
  static const Color primaryLight = Color(0xFF818CF8);// Indigo nhạt (Dark mode focus)

  // Text Colors (WCAG AA Compliant)
  static const Color textPrimary = Color(0xFFF8FAFC);  // Trắng
  static const Color textSecondary = Color(0xFFCBD5E1);// Xám sáng
  static const Color textCaption = Color(0xFFA0AEC0);  // Xám sáng (Pass contrast 5.2:1 ở 11sp)

  // Dividers & Borders
  static const Color divider = Color(0xFF2D3748);

  // Rating Status Colors
  static const Color rateHard = Color(0xFFEF4444); // Đỏ (Khó)
  static const Color rateOk = Color(0xFFF59E0B);   // Vàng/Cam (OK)
  static const Color rateEasy = Color(0xFF22C55E); // Xanh lá (Dễ)
  static const Color streakFire = Color(0xFFF97316);// Cam Streak

  // Light Mode Fallback Colors
  static const Color lightBgMain = Color(0xFFF8FAFC);
  static const Color lightBgSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
}

/// Typography Scale — Inter Font Family
abstract class AppTypography {
  static const String fontFamily = 'Inter';

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textCaption, // WCAG AA compliant on bgSurface
    height: 1.3,
  );
}
