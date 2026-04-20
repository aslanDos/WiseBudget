import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/entity_picker_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class TransactionCategoryPicker extends StatelessWidget {
  final CategoryEntity? selectedCategory;
  final List<CategoryEntity> categories;
  final ValueChanged<String> onCategorySelected;

  const TransactionCategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = selectedCategory != null
        ? AppPalette.fromValue(selectedCategory!.colorValue, defaultColor: context.c.primary)
        : context.c.onSecondary;

    return PickerField(
      icon: selectedCategory != null ? AppIcons.fromCode(selectedCategory!.iconCode) : AppIcons.grid,
      iconColor: categoryColor,
      label: selectedCategory?.name ?? context.l10n.noCategory,
      shrink: true,
      onTap: () => showEntityPickerSheet(
        context: context,
        items: categories,
        title: context.l10n.selectCategory,
        selectedId: selectedCategory?.uuid,
        getId: (c) => c.uuid,
        getTitle: (c) => c.name,
        getIcon: (c) => AppIcons.fromCode(c.iconCode),
        getColor: (ctx, c) => AppPalette.fromValue(c.colorValue, defaultColor: ctx.c.primary),
        onSelected: onCategorySelected,
      ),
    );
  }
}
