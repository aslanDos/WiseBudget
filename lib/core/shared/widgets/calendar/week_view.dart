import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/calendar/calendar_date_utils.dart';
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
        final isSelected = isSameCalendarDay(date, selectedDate);
        final isToday = isSameCalendarDay(date, today);
        final hasTransaction = hasCalendarMarkerOnDate(
          date,
          datesWithTransactions,
        );

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
}
