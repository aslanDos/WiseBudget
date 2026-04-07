import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class PickerListTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const PickerListTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isSelected ? context.c.primary.withValues(alpha: 0.1) : null,
      ),
      child: ListTile(
        leading: ColoredIconBox(
          icon: icon,
          color: iconColor,
          backgroundColor: iconBackgroundColor,
          size: 20,
          padding: 8.0,
          borderRadius: 12.0,
        ),
        title: Text(title, style: context.t.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: context.t.titleSmall)
            : null,
        trailing: isSelected
            ? Icon(Icons.check_rounded, color: context.c.primary)
            : null,
        onTap: onTap,
      ),
    );
  }
}
