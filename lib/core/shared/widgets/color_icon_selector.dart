import 'package:flutter/material.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/widgets/color_grid.dart';
import 'package:wisebuget/core/shared/widgets/color_picker_modal.dart';
import 'package:wisebuget/core/shared/widgets/form_section.dart';
import 'package:wisebuget/core/shared/widgets/icon_grid.dart';
import 'package:wisebuget/core/shared/widgets/icon_picker_modal.dart';

class ColorIconSelector extends StatelessWidget {
  final int selectedColorValue;
  final String selectedIconCode;
  final List<String> iconOptions;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<String> onIconChanged;

  const ColorIconSelector({
    super.key,
    required this.selectedColorValue,
    required this.selectedIconCode,
    required this.iconOptions,
    required this.onColorChanged,
    required this.onIconChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Color(selectedColorValue);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FormSection(
          title: context.l10n.color,
          actionLabel: context.l10n.moreColors,
          onAction: () => showColorPickerModal(
            context: context,
            selectedColorValue: selectedColorValue,
            onColorSelected: onColorChanged,
          ),
          child: ColorGrid(
            selectedColorValue: selectedColorValue,
            onColorSelected: onColorChanged,
          ),
        ),
        const SizedBox(height: 12.0),
        FormSection(
          title: context.l10n.icon,
          actionLabel: context.l10n.moreIcons,
          onAction: () => showIconPickerModal(
            context: context,
            selectedIconCode: selectedIconCode,
            selectedColor: selectedColor,
            onIconSelected: onIconChanged,
          ),
          child: IconGrid(
            iconOptions: iconOptions,
            selectedIconCode: selectedIconCode,
            selectedColor: selectedColor,
            onIconSelected: onIconChanged,
          ),
        ),
      ],
    );
  }
}
