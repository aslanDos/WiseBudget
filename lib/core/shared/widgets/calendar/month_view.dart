import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/calendar/calendar_date_utils.dart';
import 'package:wisebuget/core/shared/widgets/calendar/day_cell.dart';

class MonthView extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Set<DateTime>? datesWithTransactions;

  const MonthView({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
    this.datesWithTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final today = DateTime.now();

    // Calculate the start of the calendar grid (Monday of the week containing the 1st)
    final startWeekday = firstDayOfMonth.weekday;
    final gridStart = firstDayOfMonth.subtract(
      Duration(days: startWeekday - 1),
    );

    // Total days to show (6 weeks)
    const totalDays = 35;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        mainAxisExtent: 40,
      ),
      itemCount: totalDays,
      itemBuilder: (context, index) {
        final date = gridStart.add(Duration(days: index));
        final isCurrentMonth = date.month == month.month;
        final isSelected = isSameCalendarDay(date, selectedDate);
        final isToday = isSameCalendarDay(date, today);
        final hasTransaction = hasCalendarMarkerOnDate(
          date,
          datesWithTransactions,
        );

        return DayCell(
          date: date,
          isSelected: isSelected,
          isToday: isToday && !isSelected,
          isCurrentMonth: isCurrentMonth,
          hasTransaction: hasTransaction,
          onTap: () => onDateSelected(date),
        );
      },
    );
  }
}
