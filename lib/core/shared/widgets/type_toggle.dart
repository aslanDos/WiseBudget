import 'package:flutter/material.dart';

class TypeToggle<T> extends StatelessWidget {
  final List<TypeToggleItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color Function(T)? selectedBackgroundColor;
  final Color Function(T)? selectedForegroundColor;

  const TypeToggle({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: items
          .map(
            (item) => ButtonSegment<T>(
              value: item.value,
              label: Text(item.label),
              icon: item.icon != null ? Icon(item.icon) : null,
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (set) => onChanged(set.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return selectedBackgroundColor?.call(selected);
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return selectedForegroundColor?.call(selected);
          }
          return null;
        }),
      ),
    );
  }
}

class TypeToggleItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const TypeToggleItem({required this.value, required this.label, this.icon});
}
