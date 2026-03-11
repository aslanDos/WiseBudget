import "package:flutter/material.dart";
import "package:pie_menu/pie_menu.dart";

import "package:wisebuget/core/logger/logging.dart";

class PieThemeExtension extends ThemeExtension<PieThemeExtension> {
  final PieTheme pieTheme;

  const PieThemeExtension({required this.pieTheme});

  @override
  ThemeExtension<PieThemeExtension> copyWith({PieTheme? pieTheme}) {
    return PieThemeExtension(pieTheme: pieTheme ?? this.pieTheme);
  }

  @override
  ThemeExtension<PieThemeExtension> lerp(
    ThemeExtension<PieThemeExtension>? other,
    double t,
  ) {
    mainLogger.warning(
      "[PieThemeExtension] lerp is not available for PieTheme",
    );

    return (t < 0.5 ? this : other) as PieThemeExtension;
  }
}
