import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/app_colors.dart';

class AppColorsScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.black,
    onPrimary: AppColors.white,

    secondary: AppColors.gray,
    onSecondary: AppColors.white,

    error: AppColors.red,
    onError: AppColors.white,

    surface: AppColors.white,
    onSurface: AppColors.textDark,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,

    primary: AppColors.white,
    onPrimary: AppColors.black,

    secondary: AppColors.mediumGray,
    onSecondary: AppColors.white,

    error: AppColors.red,
    onError: AppColors.white,

    surface: AppColors.black,
    onSurface: AppColors.textLight,
  );
}
