import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class SettingsTileToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const SettingsTileToggle({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          ColoredIconBox(
            icon: icon,
            color: context.c.primary,
            size: 18,
            padding: 7,
            borderRadius: 10,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: context.t.bodyMedium)),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
