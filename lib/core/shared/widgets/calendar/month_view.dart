import 'package:flutter/material.dart';
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
    const totalDays = 42;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.0,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
        ),
        itemCount: totalDays,
        itemBuilder: (context, index) {
          final date = gridStart.add(Duration(days: index));
          final isCurrentMonth = date.month == month.month;
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, today);
          final hasTransaction = _hasTransactionOnDate(date);

          return DayCell(
            date: date,
            isSelected: isSelected,
            isToday: isToday && !isSelected,
            isCurrentMonth: isCurrentMonth,
            hasTransaction: hasTransaction,
            onTap: () => onDateSelected(date),
          );
        },
      ),
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
