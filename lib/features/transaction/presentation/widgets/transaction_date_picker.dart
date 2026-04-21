import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/picker_field.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

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
    await showModal(
      context: context,
      builder: (_) =>
          _CalendarSheet(initialDate: date, onDateSelected: onDateSelected),
    );
  }
}

class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarSheet({
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      showDragHandle: true,
      child: CupertinoCalendar(
        minimumDateTime: DateTime(2000),
        maximumDateTime: DateTime.now().add(const Duration(days: 365)),
        initialDateTime: _selected,
        mainColor: context.c.primary,
        onDateTimeChanged: (d) => _selected = d,
        onDateSelected: (d) {
          widget.onDateSelected(d);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
