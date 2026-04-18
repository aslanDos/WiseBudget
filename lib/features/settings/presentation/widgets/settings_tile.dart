import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ColoredIconBox(
              color: context.c.primary,
              icon: icon,
              size: 18,
              padding: 7,
              borderRadius: 10,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: context.t.bodyMedium)),
            Text(
              subtitle,
              style: context.t.bodySmall?.copyWith(
                color: context.c.onSurface.withAlpha(0x60),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.c.onSurface.withAlpha(0x40),
            ),
          ],
        ),
      ),
    );
  }
}
