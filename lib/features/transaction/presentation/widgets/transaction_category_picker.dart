import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/shared/widgets/picker_list_tile.dart';
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
        ? AppPalette.fromValue(
            selectedCategory!.colorValue,
            defaultColor: context.c.primary,
          )
        : context.c.onSecondary;

    return PickerField(
      icon: selectedCategory != null
          ? AppIcons.fromCode(selectedCategory!.iconCode)
          : AppIcons.grid,
      iconColor: categoryColor,
      label: selectedCategory?.name ?? 'No category',
      shrink: true,
      onTap: () => _showCategoryPicker(context),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    if (categories.isEmpty) return;

    showModal(
      context: context,
      builder: (context) => ModalSheet.scrollable(
        title: const Text('Select Category'),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.uuid == selectedCategory?.uuid;
            final color = AppPalette.fromValue(
              category.colorValue,
              defaultColor: Theme.of(context).colorScheme.primary,
            );

            return PickerListTile(
              icon: AppIcons.fromCode(category.iconCode),
              iconColor: color,
              iconBackgroundColor: color.withAlpha(0x33),
              title: category.name,
              isSelected: isSelected,
              onTap: () {
                onCategorySelected(category.uuid);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }
}
