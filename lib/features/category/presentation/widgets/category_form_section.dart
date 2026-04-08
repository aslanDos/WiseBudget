import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

/// A container with a title row and an optional action label, used to
/// wrap the color and icon pickers inside the category form.
class CategoryFormSection extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final Widget child;

  const CategoryFormSection({
    super.key,
    required this.title,
    this.actionLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: context.t.titleMedium),
              if (actionLabel != null)
                TextButton.icon(
                  onPressed: null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  label: Text(
                    actionLabel!,
                    style: context.t.bodySmall?.copyWith(
                      color: context.c.onSecondary,
                    ),
                  ),
                  icon: Icon(
                    AppIcons.chevronRight,
                    size: 14,
                    color: context.c.onSecondary,
                  ),
                  iconAlignment: IconAlignment.end,
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
