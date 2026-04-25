import 'package:cupertino_calendar_picker/cupertino_calendar_picker.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class Calendar extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  const Calendar({super.key, this.selectedDate, this.onDateSelected});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static final DateTime _minimumDate = DateTime(2000);

  late DateTime _selectedDate;

  DateTime get _maximumDate {
    final max = DateTime.now().add(const Duration(days: 365));
    return DateTime(max.year, max.month, max.day);
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = _clampDate(widget.selectedDate ?? DateTime.now());
  }

  @override
  void didUpdateWidget(covariant Calendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedDate = widget.selectedDate;
    if (selectedDate == null || _isSameDay(selectedDate, _selectedDate)) {
      return;
    }

    _selectedDate = _clampDate(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: context.c.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: context.c.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _CalendarButton(
              icon: AppIcons.chevronLeft,
              onTap: _isSameDay(_selectedDate, _minimumDate)
                  ? null
                  : () => _selectDate(
                      _selectedDate.subtract(const Duration(days: 1)),
                    ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showDatePicker(context),
                child: Center(
                  child: Text(
                    DateFormatter.format(_selectedDate),
                    style: context.t.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            _CalendarButton(
              icon: AppIcons.chevronRight,
              onTap: _isSameDay(_selectedDate, _maximumDate)
                  ? null
                  : () =>
                        _selectDate(_selectedDate.add(const Duration(days: 1))),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    await showModal(
      context: context,
      builder: (_) => _CalendarSheet(
        initialDate: _selectedDate,
        maximumDate: _maximumDate,
        onDateSelected: _selectDate,
      ),
    );
  }

  void _selectDate(DateTime date) {
    final normalized = _clampDate(date);
    setState(() => _selectedDate = normalized);
    widget.onDateSelected?.call(normalized);
  }

  DateTime _clampDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized.isBefore(_minimumDate)) return _minimumDate;
    if (normalized.isAfter(_maximumDate)) return _maximumDate;
    return normalized;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

class _CalendarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CalendarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
      color: onTap == null ? context.c.onSecondary : context.c.onSurface,
      tooltip: null,
    );
  }
}

class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime maximumDate;
  final ValueChanged<DateTime> onDateSelected;

  const _CalendarSheet({
    required this.initialDate,
    required this.maximumDate,
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
        maximumDateTime: widget.maximumDate,
        initialDateTime: _selected,
        mainColor: context.c.primary,
        onDateTimeChanged: (date) => _selected = date,
        onDateSelected: (date) {
          widget.onDateSelected(date);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
