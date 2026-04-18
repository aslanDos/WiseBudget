import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.t.labelMedium?.copyWith(
        color: context.c.onSurface.withAlpha(0x80),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}
