import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';

class AccountIconSelector extends StatelessWidget {
  final List<String> iconOptions;
  final String selectedIconCode;
  final ValueChanged<String> onSelected;

  const AccountIconSelector({
    super.key,
    required this.iconOptions,
    required this.selectedIconCode,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: iconOptions.map((iconCode) {
        final isSelected = iconCode == selectedIconCode;
        return GestureDetector(
          onTap: () => onSelected(iconCode),
          child: Container(
            width: 56.0,
            height: 56.0,
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.0),
              border: isSelected
                  ? Border.all(color: colorScheme.primary, width: 2)
                  : null,
            ),
            child: Icon(
              AppIcons.fromCode(iconCode),
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }
}
