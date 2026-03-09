import 'package:flutter/material.dart';

extension ColorsX on BuildContext {
  ColorScheme get c => Theme.of(this).colorScheme;

  TextTheme get t => Theme.of(this).textTheme;
}
