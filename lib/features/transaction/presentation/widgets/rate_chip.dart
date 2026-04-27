import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class RateChip extends StatelessWidget {
  const RateChip({super.key, required this.label, required this.isStale});

  final String label;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final color = isStale
        ? const Color(0xFFF59E0B)
        : context.c.onSurface.withAlpha(0x60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(0x18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isStale) ...[
            Icon(Icons.access_time_rounded, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: context.t.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
