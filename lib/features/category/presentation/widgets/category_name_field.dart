import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

class CategoryNameField extends StatelessWidget {
  final String name;
  final ValueChanged<String> onNameChanged;

  const CategoryNameField({
    super.key,
    required this.name,
    required this.onNameChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PickerField(
      icon: Icons.text_fields_rounded,
      label: name.isEmpty ? 'Category name' : name,
      iconColor: name.isEmpty ? context.c.onSecondary : context.c.onSurface,
      backgroundColor: context.c.surfaceContainer,
      shrink: false,
      onTap: () => _showInput(context),
    );
  }

  Future<void> _showInput(BuildContext context) async {
    final result = await showModalInput(
      context: context,
      initialValue: name,
      hintText: 'Category name',
      maxLength: CategoryEntity.maxNameLength,
    );
    if (result != null) onNameChanged(result);
  }
}
