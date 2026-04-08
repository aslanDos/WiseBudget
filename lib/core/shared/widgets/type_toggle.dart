import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
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
                    color:
                        widget.items[_selectedIndex].selectedBackgroundColor ??
                        context.c.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              // Items row
              Row(
                children: widget.items.map((item) {
                  final isSelected = item.value == widget.selected;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onChanged(item.value),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: !isSelected
                                ? context.t.bodySmall!
                                : context.t.titleSmall!.copyWith(
                                    color: context.c.onPrimary,
                                  ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.icon != null)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    width: isSelected ? 18 : 0,
                                    child: isSelected
                                        ? Icon(
                                            item.icon,
                                            size: 16,
                                            color: context.c.onPrimary,
                                          )
                                        : null,
                                  ),
                                Text(item.label),
                              ],
                            ),
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

  final Color? selectedBackgroundColor;
  final Color? selectedForegroundColor;

  const TypeToggleItem({
    required this.value,
    required this.label,
    this.icon,
    this.selectedBackgroundColor,
    this.selectedForegroundColor,
  });
}
