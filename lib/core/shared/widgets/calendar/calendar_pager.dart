import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/calendar/calendar_date_utils.dart';
import 'package:wisebuget/core/shared/widgets/calendar/month_view.dart';
import 'package:wisebuget/core/shared/widgets/calendar/week_view.dart';

class CalendarPager extends StatelessWidget {
  final bool isExpanded;
  final DateTime focusedDate;
  final DateTime selectedDate;
  final int currentPageIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final Set<DateTime>? datesWithTransactions;

  const CalendarPager({
    super.key,
    required this.isExpanded,
    required this.focusedDate,
    required this.selectedDate,
    required this.currentPageIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onDateSelected,
    required this.onExpand,
    required this.onCollapse,
    this.datesWithTransactions,
  });

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;
  static const double expandedHeight = 220.0;
  static const double collapsedHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: _onVerticalDragEnd,
      child: AnimatedContainer(
        duration: animationDuration,
        curve: animationCurve,
        height: isExpanded ? expandedHeight : collapsedHeight,
        child: PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemBuilder: (context, index) {
            final displayDate = _resolveDisplayDate(index);

            return isExpanded
                ? MonthView(
                    month: displayDate,
                    selectedDate: selectedDate,
                    onDateSelected: onDateSelected,
                    datesWithTransactions: datesWithTransactions,
                  )
                : WeekView(
                    weekStart: getCalendarWeekStart(displayDate),
                    selectedDate: selectedDate,
                    onDateSelected: onDateSelected,
                    datesWithTransactions: datesWithTransactions,
                  );
          },
        ),
      ),
    );
  }

  DateTime _resolveDisplayDate(int index) {
    final offset = index - currentPageIndex;

    if (isExpanded) {
      return DateTime(focusedDate.year, focusedDate.month + offset);
    }

    return focusedDate.add(Duration(days: offset * 7));
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > 0) {
      onExpand();
    } else if (details.primaryVelocity! < 0) {
      onCollapse();
    }
  }
}
