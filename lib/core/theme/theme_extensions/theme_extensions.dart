import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:wisebuget/core/theme/theme_extensions/pie_theme_x.dart';

extension ThemeAccessor on BuildContext {
  TextTheme get t => Theme.of(this).textTheme;
  ColorScheme get c => Theme.of(this).colorScheme;
  PieTheme get pieTheme =>
      Theme.of(this).extension<PieThemeExtension>()!.pieTheme;
  PullDownButtonTheme get pullDownTheme =>
      Theme.of(this).extension<PullDownButtonTheme>()!;
}
