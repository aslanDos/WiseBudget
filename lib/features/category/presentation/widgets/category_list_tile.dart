import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class CategoryListTile extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleVisibility;

  const CategoryListTile({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHidden = !category.visible;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                // Icon
                Builder(
                  builder: (context) {
                    final categoryColor = AppPalette.fromValue(
                      category.colorValue,
                      defaultColor: colorScheme.primary,
                    );
                    return Opacity(
                      opacity: isHidden ? 0.4 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: categoryColor.withAlpha(0x33),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(
                          category.icon,
                          color: categoryColor,
                          size: 20.0,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 12.0),

                // Name
                Expanded(
                  child: Opacity(
                    opacity: isHidden ? 0.4 : 1.0,
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Visibility toggle
                if (onToggleVisibility != null)
                  IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      isHidden ? AppIcons.eyeOff : AppIcons.eye,
                      color: isHidden
                          ? colorScheme.outline
                          : colorScheme.primary,
                      size: 20.0,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),

                const SizedBox(width: 12.0),
                // Drag handle
                Icon(
                  AppIcons.gripVertical,
                  color: colorScheme.outline,
                  size: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
