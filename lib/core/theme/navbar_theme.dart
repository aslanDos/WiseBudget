import 'package:flutter/material.dart';

class NavbarTheme extends ThemeExtension<NavbarTheme> {
  final Color backgroundColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color indicatorColor;
  final Color transactionButtonBackgroundColor;
  final Color transactionButtonForegroundColor;

  /// Size constants for the navbar layout
  static const double height = 64.0;
  static const double centerButtonSize = 56.0;
  static const double centerGapWidth = 72.0;
  static const double indicatorSize = 4.0;

  const NavbarTheme({
    required this.backgroundColor,
    required this.activeIconColor,
    required this.inactiveIconColor,
    required this.indicatorColor,
    required this.transactionButtonBackgroundColor,
    required this.transactionButtonForegroundColor,
  });

  @override
  ThemeExtension<NavbarTheme> copyWith({
    Color? backgroundColor,
    Color? activeIconColor,
    Color? inactiveIconColor,
    Color? indicatorColor,
    Color? transactionButtonBackgroundColor,
    Color? transactionButtonForegroundColor,
  }) {
    return NavbarTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      activeIconColor: activeIconColor ?? this.activeIconColor,
      inactiveIconColor: inactiveIconColor ?? this.inactiveIconColor,
      indicatorColor: indicatorColor ?? this.indicatorColor,
      transactionButtonBackgroundColor:
          transactionButtonBackgroundColor ??
          this.transactionButtonBackgroundColor,
      transactionButtonForegroundColor:
          transactionButtonForegroundColor ??
          this.transactionButtonForegroundColor,
    );
  }

  @override
  ThemeExtension<NavbarTheme> lerp(
    covariant ThemeExtension<NavbarTheme>? other,
    double t,
  ) {
    if (other is! NavbarTheme) return this;

    return NavbarTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      activeIconColor: Color.lerp(activeIconColor, other.activeIconColor, t)!,
      inactiveIconColor:
          Color.lerp(inactiveIconColor, other.inactiveIconColor, t)!,
      indicatorColor: Color.lerp(indicatorColor, other.indicatorColor, t)!,
      transactionButtonBackgroundColor: Color.lerp(
        transactionButtonBackgroundColor,
        other.transactionButtonBackgroundColor,
        t,
      )!,
      transactionButtonForegroundColor: Color.lerp(
        transactionButtonForegroundColor,
        other.transactionButtonForegroundColor,
        t,
      )!,
    );
  }
}
