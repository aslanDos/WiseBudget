import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const ToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.c.secondary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        focusColor: Theme.of(context).focusColor,
        hoverColor: Theme.of(context).hoverColor,
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: iconColor.withValues(alpha: 0.3),
                ),
                child: Icon(icon, size: 28.0, color: iconColor),
              ),
              const SizedBox(height: 12.0),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4.0),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: context.c.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
