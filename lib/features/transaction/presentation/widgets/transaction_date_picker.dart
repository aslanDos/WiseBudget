import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class TransactionDatePicker extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateSelected;

  const TransactionDatePicker({
    super.key,
    required this.date,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PickerField(
      icon: AppIcons.calendar,
      iconBackgroundColor: context.c.surfaceContainer,
      label: DateFormatter.format(date),
      shrink: true,
      onTap: () => _showDatePicker(context),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) onDateSelected(picked);
  }
}
