import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/calendar/month_header.dart';
import 'package:wisebuget/core/shared/widgets/calendar/month_view.dart';
import 'package:wisebuget/core/shared/widgets/calendar/week_day_labels.dart';
import 'package:wisebuget/core/shared/widgets/calendar/week_view.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class Calendar extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;
  final Set<DateTime>? datesWithTransactions;

  const Calendar({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.onMonthChanged,
    this.datesWithTransactions,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDate;
  late DateTime _selectedDate;
  bool _isExpanded = false;

  late final PageController _pageController;
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
    _focusedDate = _selectedDate;
    _currentPageIndex = 1000; // Start in the middle for infinite scroll
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.c.shadow.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month header
          MonthHeader(
            focusedDate: _focusedDate,
            onPrevious: _goToPreviousPage,
            onNext: _goToNextPage,
          ),

          // Week day labels
          const WeekDayLabels(),
          const SizedBox(height: 8.0),

          // Calendar grid
          GestureDetector(
            onVerticalDragEnd: _onVerticalDragEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isExpanded ? 220.0 : 56.0,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final offset = index - _currentPageIndex;
                  final displayDate = _isExpanded
                      ? DateTime(_focusedDate.year, _focusedDate.month + offset)
                      : _focusedDate.add(Duration(days: offset * 7));

                  return _isExpanded
                      ? MonthView(
                          month: displayDate,
                          selectedDate: _selectedDate,
                          onDateSelected: _onDateSelected,
                          datesWithTransactions: widget.datesWithTransactions,
                        )
                      : WeekView(
                          weekStart: _getWeekStart(displayDate),
                          selectedDate: _selectedDate,
                          onDateSelected: _onDateSelected,
                          datesWithTransactions: widget.datesWithTransactions,
                        );
                },
              ),
            ),
          ),

          // Drag handle
          GestureDetector(
            onTap: _toggleExpanded,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: context.c.outline.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _focusedDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  void _onPageChanged(int index) {
    final offset = index - _currentPageIndex;
    setState(() {
      if (_isExpanded) {
        _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + offset);
      } else {
        _focusedDate = _focusedDate.add(Duration(days: offset * 7));
      }
      _currentPageIndex = index;
    });
    widget.onMonthChanged?.call(_focusedDate);
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
    // Джампаем без анимации, чтобы не было визуального скачка
    _pageController.jumpToPage(1000);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > 0) {
      // Swiping down - expand
      setState(() => _isExpanded = true);
      _pageController.jumpToPage(1000);
    } else if (details.primaryVelocity! < 0) {
      // Swiping up - collapse
      setState(() => _isExpanded = false);
      _pageController.jumpToPage(1000);
    }
  }
}
