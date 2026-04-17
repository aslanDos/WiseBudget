import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/color_grid.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';

Future<void> showColorPickerModal({
  required BuildContext context,
  required int selectedColorValue,
  required ValueChanged<int> onColorSelected,
}) {
  return showModal<void>(
    context: context,
    builder: (context) => ModalSheet.scrollable(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: ColorGrid(
          selectedColorValue: selectedColorValue,
          showAll: true,
          onColorSelected: (value) {
            onColorSelected(value);
            Navigator.pop(context);
          },
        ),
      ),
    ),
  );
}
