import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/calendar/calendar_pager.dart';
import 'package:wisebuget/core/shared/widgets/calendar/month_header.dart';
import 'package:wisebuget/core/shared/widgets/calendar/week_day_labels.dart';
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

class _CalendarState extends State<Calendar> {
  static const int _initialPageIndex = 1000;
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const Curve _animationCurve = Curves.easeInOut;

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
    _currentPageIndex = _initialPageIndex;
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
      duration: _animationDuration,
      curve: _animationCurve,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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

          CalendarPager(
            isExpanded: _isExpanded,
            focusedDate: _focusedDate,
            selectedDate: _selectedDate,
            currentPageIndex: _currentPageIndex,
            pageController: _pageController,
            onPageChanged: _onPageChanged,
            onDateSelected: _onDateSelected,
            onExpand: _expand,
            onCollapse: _collapse,
            datesWithTransactions: widget.datesWithTransactions,
          ),

          GestureDetector(
            onTap: _toggleExpanded,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              if (details.primaryVelocity! > 0) _expand();
              if (details.primaryVelocity! < 0) _collapse();
            },
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
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: _animationDuration,
      curve: _animationCurve,
    );
  }

  void _toggleExpanded() {
    if (_isExpanded) {
      _collapse();
    } else {
      _expand();
    }
  }

  void _expand() {
    _setExpanded(true);
  }

  void _collapse() {
    _setExpanded(false);
  }

  void _setExpanded(bool isExpanded) {
    setState(() => _isExpanded = isExpanded);
    _pageController.jumpToPage(_initialPageIndex);
  }
}
