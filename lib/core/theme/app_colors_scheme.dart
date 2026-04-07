import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/app_colors.dart';

class AppColorsScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.blue6,
    onPrimary: AppColors.white,

    secondary: AppColors.black4,
    onSecondary: AppColors.black7,

    error: AppColors.red,
    onError: AppColors.white,

    surface: AppColors.black4,
    onSurface: AppColors.black13,

    surfaceContainer: AppColors.white,

    outline: AppColors.black5,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,

    primary: AppColors.blue5,
    onPrimary: AppColors.white,

    secondary: AppColors.black8,
    onSecondary: AppColors.white,

    error: AppColors.red,
    onError: AppColors.white,

    surface: AppColors.black13,
    onSurface: AppColors.black2,

    surfaceContainer: AppColors.black11,

    outline: AppColors.black8,
  );
}
