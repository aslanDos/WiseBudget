import 'package:flutter/widgets.dart';

abstract final class AppBreakpoints {
  static const double compact = 360;
  static const double medium = 600;
  static const double expanded = 840;
  static const double large = 1200;

  static const double comfortablePadding = 720;
  static const double formWide = 860;
  static const double analyticsWide = 920;
  static const double detailWide = 960;

  static const double summaryStack = 340;
  static const double pickerStack = 360;
  static const double chartHeaderStack = 380;
  static const double chartLegendStack = 520;
  static const double progressStack = 420;

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= medium;
  }
}
