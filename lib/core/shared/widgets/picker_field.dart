import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

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
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    this.trailing,
    this.shrink = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? context.c.secondary,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
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
              // Value / trailing / chevron
              if (trailing != null) ...[
                const SizedBox(width: 8.0),
                trailing!,
              ] else if (value != null) ...[
                const SizedBox(width: 8.0),
                Text(
                  value!,
                  style: (valueStyle ?? context.t.bodyMedium)?.copyWith(
                    color: context.c.onSurface,
                  ),
                ),
                if (showChevron) ...[
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: context.c.onSecondary,
                  ),
                ],
              ] else if (showChevron) ...[
                const SizedBox(width: 8.0),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: context.c.onSecondary,
                ),
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
    this.borderRadius = 12.0,
    this.showDividers = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? context.c.secondary,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            // Override the background color of child PickerFields to transparent
            _PickerFieldWrapper(child: children[i]),
            if (showDividers && i < children.length - 1)
              Divider(height: 1, thickness: 1, color: context.c.secondary),
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
        shrink: pickerField.shrink,
      );
    }
    return child;
  }
}
