import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/calendar/day_cell.dart';

class WeekView extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Set<DateTime>? datesWithTransactions;

  const WeekView({
    super.key,
    required this.weekStart,
    required this.selectedDate,
    required this.onDateSelected,
    this.datesWithTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Row(
      children: List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        final isSelected = _isSameDay(date, selectedDate);
        final isToday = _isSameDay(date, today);
        final hasTransaction = _hasTransactionOnDate(date);

        return Expanded(
          child: DayCell(
            date: date,
            isSelected: isSelected,
            isToday: isToday && !isSelected,
            hasTransaction: hasTransaction,
            onTap: () => onDateSelected(date),
          ),
        );
      }),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasTransactionOnDate(DateTime date) {
    if (datesWithTransactions == null) return false;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return datesWithTransactions!.contains(normalizedDate);
  }
}
