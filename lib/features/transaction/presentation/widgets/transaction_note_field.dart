import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class TransactionNoteField extends StatelessWidget {
  final String note;
  final ValueChanged<String> onNoteChanged;

  const TransactionNoteField({
    super.key,
    required this.note,
    required this.onNoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PickerField(
      icon: AppIcons.feather,
      iconBackgroundColor: context.c.surfaceContainer,
      label: note.isEmpty ? 'Note' : note,
      shrink: false,
      onTap: () => _showNoteInput(context),
    );
  }

  Future<void> _showNoteInput(BuildContext context) async {
    final result = await showModalInput(
      context: context,
      initialValue: note,
      hintText: 'Add a note...',
      maxLength: 200,
    );
    if (result != null) onNoteChanged(result);
  }
}
