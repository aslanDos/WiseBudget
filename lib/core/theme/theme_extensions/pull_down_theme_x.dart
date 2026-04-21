import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';

PullDownButtonTheme buildPullDownTheme({
  required ColorScheme scheme,
  required TextTheme textTheme,
}) {
  return PullDownButtonTheme(
    routeTheme: PullDownMenuRouteTheme(
      // Semi-transparent so the native blur effect kicks in
      backgroundColor: scheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      width: 180,
    ),
    itemTheme: PullDownMenuItemTheme(
      textStyle: textTheme.bodyMedium,
      destructiveColor: scheme.error,
      onPressedBackgroundColor: scheme.surface,
      checkmark: AppIcons.check,
    ),
  );
}
