import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';

/// A grid of color circles for selecting a color.
class ColorPicker extends StatelessWidget {
  final int? selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: AppPalette.colors.map((colorValue) {
        final isSelected = colorValue == selectedColorValue;
        final color = Color(colorValue);

        return GestureDetector(
          onTap: () => onColorSelected(colorValue),
          child: Container(
            width: 48.0,
            height: 48.0,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: colorScheme.outline,
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withAlpha(0x80),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: _contrastColor(color),
                    size: 24.0,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  /// Returns white or black depending on which provides better contrast
  Color _contrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
