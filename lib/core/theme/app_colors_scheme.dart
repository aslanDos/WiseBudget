import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/app_colors.dart';

class AppColorsScheme {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,

    primary: AppColors.blue,
    onPrimary: AppColors.base,

    secondary: AppColors.mauve,
    onSecondary: AppColors.base,

    error: AppColors.red,
    onError: Colors.white,

    surface: AppColors.text,
    onSurface: AppColors.mantle,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,

    primary: AppColors.blue,
    onPrimary: AppColors.base,

    secondary: AppColors.mauve,
    onSecondary: AppColors.base,

    error: AppColors.red,
    onError: AppColors.base,

    surface: AppColors.mantle,
    onSurface: AppColors.text,
  );
}
