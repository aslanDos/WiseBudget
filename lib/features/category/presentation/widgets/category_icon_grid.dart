import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

const _kGridColumns = 6;
const _kGridSpacing = 10.0;

/// Default icon options available for category creation.
const kCategoryIconOptions = [
  'utensils',
  'shoppingBag',
  'shoppingCart',
  'receipt',
  'car',
  'bus',
  'plane',
  'bike',
  'home',
  'building',
  'briefCase',
  'wallet',
  'gamepad',
  'music',
  'heart',
  'star',
  'coffee',
  'gift',
  'book',
  'graduationCap',
  'phone',
  'laptop',
  'dumbbell',
  'stethoscope',
  'zap',
  'globe',
];

class CategoryIconGrid extends StatelessWidget {
  final List<String> iconOptions;
  final String selectedIconCode;
  final Color selectedColor;
  final ValueChanged<String> onIconSelected;

  const CategoryIconGrid({
    super.key,
    required this.iconOptions,
    required this.selectedIconCode,
    required this.selectedColor,
    required this.onIconSelected,
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
      itemCount: iconOptions.length.clamp(0, _kGridColumns * 2),
      itemBuilder: (context, index) {
        final iconCode = iconOptions[index];
        final isSelected = iconCode == selectedIconCode;

        return GestureDetector(
          onTap: () => onIconSelected(iconCode),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              AppIcons.fromCode(iconCode),
              size: 20,
              color: isSelected
                  ? (selectedColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white)
                  : context.c.onSecondary,
            ),
          ),
        );
      },
    );
  }
}
