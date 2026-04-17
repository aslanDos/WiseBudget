import 'package:flutter/material.dart';

final TextTheme appTextTheme = TextTheme(
  headlineLarge: AppTextStyle.heading36,
  headlineMedium: AppTextStyle.heading24,

  titleLarge: AppTextStyle.subHeading20,
  titleMedium: AppTextStyle.subHeading16,
  titleSmall: AppTextStyle.subHeading12,

  bodyLarge: AppTextStyle.body16,
  bodyMedium: AppTextStyle.body14,
  bodySmall: AppTextStyle.body12,
);

class AppTextStyle {
  AppTextStyle._();

  static const TextStyle heading36 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w500,
    height: 1.1,
  );

  static const TextStyle heading24 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.1,
  );

  static const TextStyle subHeading20 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle subHeading16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
  );

  static const TextStyle subHeading12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const TextStyle body16 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle body14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.28,
  );

  static const TextStyle body12 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.24,
  );
}
