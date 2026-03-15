import 'package:flutter/material.dart';

/// A reusable picker field widget that looks like an iOS settings cell.
///
/// This widget displays a tappable row with an icon on the left and text on the right.
/// It's designed to be used for selecting values like dates, categories, accounts, etc.
///
/// Example usage:
/// ```dart
/// PickerField(
///   icon: Icons.calendar_today,
///   label: 'Date',
///   value: 'Today',
///   onTap: () => _showDatePicker(),
/// )
/// ```
class PickerField extends StatelessWidget {
  /// The icon displayed on the left side of the field.
  final IconData icon;

  /// The color of the icon. Defaults to theme's onSurfaceVariant.
  final Color? iconColor;

  /// The background color of the icon container. If provided, the icon
  /// will be displayed inside a rounded container with this background.
  final Color? iconBackgroundColor;

  /// The label text displayed next to the icon.
  final String label;

  /// Optional value text displayed on the right side.
  /// If null, only the label is shown.
  final String? value;

  /// The text style for the value. Defaults to theme's bodyMedium.
  final TextStyle? valueStyle;

  /// Whether to show a chevron icon on the right side.
  final bool showChevron;

  /// The callback triggered when the field is tapped.
  final VoidCallback? onTap;

  /// The background color of the field. Defaults to a light grey.
  final Color? backgroundColor;

  /// The border radius of the field. Defaults to 16.0.
  final double borderRadius;

  /// The padding inside the field.
  final EdgeInsetsGeometry padding;

  /// Optional trailing widget to display instead of the default chevron/value.
  final Widget? trailing;

  const PickerField({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.iconBackgroundColor,
    this.value,
    this.valueStyle,
    this.showChevron = true,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 14.0,
    this.padding = EdgeInsets.zero,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainerHighest.withAlpha(0x80);

    final effectiveIconColor = iconColor ?? colorScheme.onSurfaceVariant;

    return Material(
      color: effectiveBackgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              // Icon (optionally with background)
              if (iconBackgroundColor != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Icon(icon, size: 20.0, color: effectiveIconColor),
                )
              else
                Icon(icon, size: 24.0, color: effectiveIconColor),
              const SizedBox(width: 12.0),
              // Label
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              // Value or trailing widget
              if (trailing != null)
                trailing!
              else ...[
                if (value != null)
                  Text(
                    value!,
                    style:
                        valueStyle ??
                        theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                if (showChevron) ...[
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.chevron_right,
                    size: 20.0,
                    color: colorScheme.onSurfaceVariant.withAlpha(0x80),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A group of picker fields displayed in a single card-like container.
///
/// Use this to group related picker fields together with visual separation.
///
/// Example usage:
/// ```dart
/// PickerFieldGroup(
///   children: [
///     PickerField(icon: Icons.calendar_today, label: 'Date', value: 'Today'),
///     PickerField(icon: Icons.category, label: 'Category', value: 'Food'),
///     PickerField(icon: Icons.notes, label: 'Note'),
///   ],
/// )
/// ```
class PickerFieldGroup extends StatelessWidget {
  /// The list of picker fields to display.
  final List<Widget> children;

  /// The background color of the group container.
  final Color? backgroundColor;

  /// The border radius of the group container. Defaults to 16.0.
  final double borderRadius;

  /// Whether to show dividers between items.
  final bool showDividers;

  const PickerFieldGroup({
    super.key,
    required this.children,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveBackgroundColor =
        backgroundColor ?? colorScheme.surfaceContainerHighest.withAlpha(0x80);

    return Container(
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            // Override the background color of child PickerFields to transparent
            _PickerFieldWrapper(child: children[i]),
            if (showDividers && i < children.length - 1)
              Padding(
                padding: const EdgeInsets.only(left: 52.0),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: colorScheme.outlineVariant.withAlpha(0x40),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PickerFieldWrapper extends StatelessWidget {
  final Widget child;

  const _PickerFieldWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    // If the child is a PickerField, rebuild it with transparent background
    if (child is PickerField) {
      final pickerField = child as PickerField;
      return PickerField(
        icon: pickerField.icon,
        label: pickerField.label,
        iconColor: pickerField.iconColor,
        iconBackgroundColor: pickerField.iconBackgroundColor,
        value: pickerField.value,
        valueStyle: pickerField.valueStyle,
        showChevron: pickerField.showChevron,
        onTap: pickerField.onTap,
        backgroundColor: Colors.transparent,
        borderRadius: 0,
        padding: pickerField.padding,
        trailing: pickerField.trailing,
      );
    }
    return child;
  }
}
