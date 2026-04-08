import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/icon_groups.dart';
import 'package:wisebuget/core/shared/widgets/icon_grid.dart';
import 'package:wisebuget/core/shared/widgets/modal_sheet.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

Future<void> showIconPickerModal({
  required BuildContext context,
  required String selectedIconCode,
  required Color selectedColor,
  required ValueChanged<String> onIconSelected,
}) {
  return showModal<void>(
    context: context,
    builder: (context) => ModalSheet.scrollable(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        itemCount: kIconGroups.length,
        itemBuilder: (context, index) {
          final group = kIconGroups[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(group.name, style: context.t.titleSmall),
                const SizedBox(height: 8.0),
                IconGrid(
                  iconOptions: group.icons,
                  selectedIconCode: selectedIconCode,
                  selectedColor: selectedColor,
                  showAll: true,
                  onIconSelected: (code) {
                    onIconSelected(code);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
