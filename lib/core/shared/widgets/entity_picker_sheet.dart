import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_list_tile.dart';

void showEntityPickerSheet<T>({
  required BuildContext context,
  required List<T> items,
  required String title,
  required String? selectedId,
  required String Function(T) getId,
  required String Function(T) getTitle,
  String? Function(T)? getSubtitle,
  required IconData Function(T) getIcon,
  required Color Function(BuildContext, T) getColor,
  required ValueChanged<String> onSelected,
}) {
  if (items.isEmpty) return;

  showModal(
    context: context,
    builder: (context) => ModalSheet.scrollable(
      title: Text(title),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final id = getId(item);
          final color = getColor(context, item);

          return PickerListTile(
            icon: getIcon(item),
            iconColor: color,
            iconBackgroundColor: color.withAlpha(0x33),
            title: getTitle(item),
            subtitle: getSubtitle?.call(item),
            isSelected: id == selectedId,
            onTap: () {
              onSelected(id);
              Navigator.pop(context);
            },
          );
        },
      ),
    ),
  );
}
