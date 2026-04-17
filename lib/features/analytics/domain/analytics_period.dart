import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class AnalyticsPeriod extends Equatable {
  const AnalyticsPeriod();

  DateTimeRange get range;

  /// Full descriptive label used in the picker list.
  String get label;

  /// Short label shown on the chip (e.g. "Apr 2025", "This week").
  String get chipLabel;

  /// Whether this period has enough data points to render a bar chart.
  /// Single-day periods (Today / Yesterday) skip the chart.
  bool get hasChart => true;
}

// ─────────────────────────────────────────────────────────────────────────────

final class TodayPeriod extends AnalyticsPeriod {
  const TodayPeriod();

  @override
  DateTimeRange get range {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  @override String get label => 'Today';
  @override String get chipLabel => 'Today';
  @override bool get hasChart => false;

  @override List<Object?> get props => [];
}

final class YesterdayPeriod extends AnalyticsPeriod {
  const YesterdayPeriod();

  @override
  DateTimeRange get range {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return DateTimeRange(
      start: DateTime(d.year, d.month, d.day),
      end: DateTime(d.year, d.month, d.day, 23, 59, 59),
    );
  }

  @override String get label => 'Yesterday';
  @override String get chipLabel => 'Yesterday';
  @override bool get hasChart => false;

  @override List<Object?> get props => [];
}

final class ThisWeekPeriod extends AnalyticsPeriod {
  const ThisWeekPeriod();

  @override
  DateTimeRange get range {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return DateTimeRange(
      start: start,
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  @override String get label => 'This week';
  @override String get chipLabel => 'This week';

  @override List<Object?> get props => [];
}

final class ThisMonthPeriod extends AnalyticsPeriod {
  const ThisMonthPeriod();

  static const _abbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  DateTimeRange get range {
    final now = DateTime.now();
    return DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  @override String get label => 'This month';

  @override String get chipLabel {
    final now = DateTime.now();
    return '${_abbr[now.month - 1]} ${now.year}';
  }

  @override List<Object?> get props => [];
}

final class PrevMonthPeriod extends AnalyticsPeriod {
  const PrevMonthPeriod();

  static const _abbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  DateTimeRange get range {
    final now = DateTime.now();
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    return DateTimeRange(
      start: DateTime(prevYear, prevMonth, 1),
      // day 0 of next month = last day of prevMonth; Dart handles month overflow
      end: DateTime(prevYear, prevMonth + 1, 0, 23, 59, 59),
    );
  }

  @override String get label => 'Previous month';

  @override String get chipLabel {
    final now = DateTime.now();
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    return '${_abbr[prevMonth - 1]} $prevYear';
  }

  @override List<Object?> get props => [];
}

final class ThisYearPeriod extends AnalyticsPeriod {
  const ThisYearPeriod();

  @override
  DateTimeRange get range {
    final year = DateTime.now().year;
    return DateTimeRange(
      start: DateTime(year, 1, 1),
      end: DateTime(year, 12, 31, 23, 59, 59),
    );
  }

  @override String get label => 'This year';
  @override String get chipLabel => '${DateTime.now().year}';

  @override List<Object?> get props => [];
}

final class CustomPeriod extends AnalyticsPeriod {
  final DateTime start;
  final DateTime end;

  const CustomPeriod({required this.start, required this.end});

  static const _abbr = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  DateTimeRange get range => DateTimeRange(start: start, end: end);

  @override String get label => 'Custom range';

  @override String get chipLabel {
    final sm = _abbr[start.month - 1];
    final em = _abbr[end.month - 1];
    if (start.year == end.year) {
      return '${start.day} $sm – ${end.day} $em';
    }
    return '${start.day} $sm ${start.year} – ${end.day} $em ${end.year}';
  }

  @override List<Object?> get props => [start, end];
}
