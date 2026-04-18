import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class SettingsCard extends StatelessWidget {
  final List<Widget> items;

  const SettingsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 56,
                endIndent: 0,
                color: context.c.onSurface.withAlpha(0x14),
              ),
            items[i],
          ],
        ],
      ),
    );
  }
}
