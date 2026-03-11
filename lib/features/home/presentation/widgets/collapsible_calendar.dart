import 'package:flutter/material.dart';

class CollapsibleCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;
  final Set<DateTime>? datesWithTransactions;

  const CollapsibleCalendar({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.onMonthChanged,
    this.datesWithTransactions,
  });

  @override
  State<CollapsibleCalendar> createState() => _CollapsibleCalendarState();
}

class _CollapsibleCalendarState extends State<CollapsibleCalendar>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedDate;
  late DateTime _selectedDate;
  bool _isExpanded = false;

  late final PageController _pageController;
  late int _currentPageIndex;

  static const _weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month header
          _MonthHeader(
            focusedDate: _focusedDate,
            onPrevious: _goToPreviousPage,
            onNext: _goToNextPage,
          ),

          // Week day labels
          const _WeekDayLabels(weekDays: _weekDays),
          const SizedBox(height: 8.0),

          // Calendar grid
          GestureDetector(
            onVerticalDragEnd: _onVerticalDragEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isExpanded ? 280.0 : 52.0,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final offset = index - _currentPageIndex;
                  final displayDate = _isExpanded
                      ? DateTime(_focusedDate.year, _focusedDate.month + offset)
                      : _focusedDate.add(Duration(days: offset * 7));

                  return _isExpanded
                      ? _MonthView(
                          month: displayDate,
                          selectedDate: _selectedDate,
                          onDateSelected: _onDateSelected,
                          datesWithTransactions: widget.datesWithTransactions,
                        )
                      : _WeekView(
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
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
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! > 0) {
      // Swiping down - expand
      setState(() => _isExpanded = true);
    } else if (details.primaryVelocity! < 0) {
      // Swiping up - collapse
      setState(() => _isExpanded = false);
    }
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime focusedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.focusedDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
            visualDensity: VisualDensity.compact,
          ),
          Text(
            _formatMonth(focusedDate),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

class _WeekDayLabels extends StatelessWidget {
  final List<String> weekDays;

  const _WeekDayLabels({required this.weekDays});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: weekDays
            .map(
              (day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Set<DateTime>? datesWithTransactions;

  const _WeekView({
    required this.weekStart,
    required this.selectedDate,
    required this.onDateSelected,
    this.datesWithTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final isSelected = _isSameDay(date, selectedDate);
          final isToday = _isSameDay(date, today);
          final hasTransaction = _hasTransactionOnDate(date);

          return Expanded(
            child: _DayCell(
              date: date,
              isSelected: isSelected,
              isToday: isToday && !isSelected,
              hasTransaction: hasTransaction,
              onTap: () => onDateSelected(date),
            ),
          );
        }),
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

class _MonthView extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final Set<DateTime>? datesWithTransactions;

  const _MonthView({
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

          return _DayCell(
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

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;
  final bool hasTransaction;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    this.isCurrentMonth = true,
    this.hasTransaction = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color? backgroundColor;
    Color textColor;

    if (isSelected) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isToday) {
      // Today but not selected - just primary text color, no background
      backgroundColor = null;
      textColor = colorScheme.primary;
    } else {
      backgroundColor = null;
      textColor = isCurrentMonth
          ? colorScheme.onSurface
          : colorScheme.outline.withValues(alpha: 0.4);
    }

    // Dot color: white when selected, primary otherwise
    final dotColor = isSelected ? colorScheme.onPrimary : colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: isSelected || isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            if (hasTransaction)
              Container(
                width: 5.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5.0), // Placeholder to maintain alignment
          ],
        ),
      ),
    );
  }
}
