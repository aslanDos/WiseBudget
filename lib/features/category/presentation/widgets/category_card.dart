import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleVisibility;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
    this.onDelete,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final isHidden = !category.visible;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.0),
            child: Row(
              children: [
                Opacity(
                  opacity: isHidden ? 0.4 : 1.0,
                  child: ColoredIconBox(
                    icon: category.icon,
                    color: AppPalette.fromValue(
                      category.colorValue,
                      defaultColor: context.c.primary,
                    ),
                    padding: 6.0,
                    borderRadius: 12.0,
                  ),
                ),

                const SizedBox(width: 12.0),

                // Name
                Expanded(
                  child: Opacity(
                    opacity: isHidden ? 0.4 : 1.0,
                    child: Text(
                      category.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),

                // Visibility toggle
                if (onToggleVisibility != null)
                  IconButton(
                    onPressed: onToggleVisibility,
                    icon: Icon(
                      isHidden ? AppIcons.eyeOff : AppIcons.eye,
                      color: isHidden ? context.c.outline : context.c.primary,
                      size: 20.0,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),

                const SizedBox(width: 12.0),
                // Drag handle
                Icon(
                  AppIcons.gripVertical,
                  color: context.c.onSecondary,
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
