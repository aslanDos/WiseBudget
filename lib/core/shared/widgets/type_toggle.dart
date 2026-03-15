import 'package:flutter/material.dart';

class TypeToggle<T> extends StatefulWidget {
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
  State<TypeToggle<T>> createState() => _TypeToggleState<T>();
}

class _TypeToggleState<T> extends State<TypeToggle<T>> {
  int get _selectedIndex =>
      widget.items.indexWhere((item) => item.value == widget.selected);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(0x80),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / widget.items.length;

          return Stack(
            children: [
              // Sliding pill indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                left: _selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.selectedBackgroundColor
                            ?.call(widget.selected) ??
                        colorScheme.primary,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(0x1A),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Items row
              Row(
                children: widget.items.map((item) {
                  final isSelected = item.value == widget.selected;
                  final foregroundColor = isSelected
                      ? (widget.selectedForegroundColor?.call(item.value) ??
                          colorScheme.onPrimary)
                      : colorScheme.onSurfaceVariant;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onChanged(item.value),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: theme.textTheme.labelLarge!.copyWith(
                              color: foregroundColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            child: Text(item.label),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
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
