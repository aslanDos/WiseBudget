import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';

const _kGridColumns = 6;
const _kGridSpacing = 10.0;

class CategoryColorGrid extends StatelessWidget {
  final int selectedColorValue;
  final ValueChanged<int> onColorSelected;

  const CategoryColorGrid({
    super.key,
    required this.selectedColorValue,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _kGridColumns,
        mainAxisSpacing: _kGridSpacing,
        crossAxisSpacing: _kGridSpacing,
      ),
      itemCount: AppPalette.colors.length.clamp(0, _kGridColumns * 2),
      itemBuilder: (context, index) {
        final colorValue = AppPalette.colors[index];
        final color = Color(colorValue);
        final isSelected = colorValue == selectedColorValue;

        return GestureDetector(
          onTap: () => onColorSelected(colorValue),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2.5,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
