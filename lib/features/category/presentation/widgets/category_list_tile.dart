import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class CategoryListTile extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryListTile({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                // Drag handle
                Icon(
                  AppIcons.gripVertical,
                  color: colorScheme.outline,
                  size: 20.0,
                ),
                const SizedBox(width: 12.0),
                // Icon
                Builder(
                  builder: (context) {
                    final categoryColor = AppPalette.fromValue(
                      category.colorValue,
                      defaultColor: colorScheme.primary,
                    );
                    return Container(
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
                    );
                  },
                ),
                const SizedBox(width: 12.0),
                // Name
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                // Delete button
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      AppIcons.trash,
                      color: colorScheme.error,
                      size: 20.0,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
