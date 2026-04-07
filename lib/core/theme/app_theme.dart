import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:wisebuget/core/constants/app_constants.dart';
import 'package:wisebuget/core/theme/app_colors_scheme.dart';
import 'package:wisebuget/core/theme/app_text_theme.dart';
import 'package:wisebuget/core/theme/extensions/pie_theme_x.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';

class AppTheme {
  static const fontFamily = AppConstants.fontFamilyPrimary;

  static final ThemeData light = _buildTheme(AppColorsScheme.light);
  static final ThemeData dark = _buildTheme(AppColorsScheme.dark);

  // late final PieTheme pieTheme; for PieMenu

  static ThemeData _buildTheme(ColorScheme scheme) {
    final bool isDark = scheme.brightness == Brightness.dark;

    final TextTheme textTheme = appTextTheme.apply(
      fontFamily: fontFamily,
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      decorationColor: scheme.onSurface,
    );

    final PieTheme pieTheme = PieTheme(
      buttonTheme: PieButtonTheme(
        backgroundColor: scheme.secondary,
        iconColor: scheme.onSurface,
      ),
      buttonThemeHovered: PieButtonTheme(
        backgroundColor: scheme.secondary,
        iconColor: scheme.primary,
      ),
      overlayColor: scheme.surface.withAlpha(0xe0),
      pointerColor: Colors.transparent,
      angleOffset: 0.0,
      pointerSize: 2.0,
      tooltipTextStyle: appTextTheme.headlineLarge?.copyWith(
        color: scheme.onSurface,
      ),
      rightClickShowsMenu: true,
      menuAlignment: Alignment.center,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: scheme,
      brightness: scheme.brightness,
      textTheme: textTheme,
      appBarTheme: AppBarThemeData(
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        backgroundColor: scheme.surface,
      ),
      cardTheme: CardThemeData(
        color: scheme.secondary,
        surfaceTintColor: scheme.primary,
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.titleLarge!.copyWith(color: scheme.onSurface),
        selectedColor: scheme.secondary,
      ),
      extensions: [
        PieThemeExtension(pieTheme: pieTheme),
        NavbarTheme(
          backgroundColor: scheme.surface,
          activeIconColor: scheme.primary,
          inactiveIconColor: scheme.onSecondary,
          transactionButtonBackgroundColor: scheme.primary,
          transactionButtonForegroundColor: scheme.onPrimary,
        ),
      ],
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24.0, fill: 1.0),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStateColor.fromMap({
            WidgetState.selected: scheme.primary,
            ~WidgetState.selected: scheme.onSurface,
          }),
          backgroundColor: WidgetStateColor.fromMap({
            WidgetState.selected: scheme.primary,
            WidgetState.pressed: scheme.onSurface.withAlpha(0x42),
            WidgetState.hovered: scheme.onSurface.withAlpha(0x28),
            WidgetState.focused: scheme.onSurface.withAlpha(0x28),
            WidgetState.any: Colors.transparent,
          }),
        ),
      ),
      highlightColor: scheme.onSurface.withAlpha(0x16),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        selectedTileColor: scheme.secondary,
        selectedColor: isDark ? scheme.primary : null,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurface,
        ),
      ),
    );
  }
}
