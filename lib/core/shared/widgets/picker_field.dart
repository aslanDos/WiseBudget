import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

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

  final bool shrink;

  const PickerField({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.iconBackgroundColor,
    this.value,
    this.valueStyle,
    this.showChevron = false,
    this.onTap,
    this.backgroundColor,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.trailing,
    this.shrink = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? context.c.secondary,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: shrink ? MainAxisSize.min : MainAxisSize.max,
            children: [
              // Icon
              Icon(icon, size: 16, color: iconColor ?? context.c.onSecondary),
              const SizedBox(width: 12.0),
              // Label
              if (shrink)
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.bodyMedium?.copyWith(
                      color: iconColor ?? context.c.onSecondary,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.t.bodyMedium?.copyWith(
                      color: iconColor ?? context.c.onSecondary,
                    ),
                  ),
                ),
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
