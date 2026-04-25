import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_occurrence.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';

class RecurringTransactionScheduler {
  const RecurringTransactionScheduler();

  bool occursOnDate(RecurringTransactionEntity template, DateTime date) {
    if (!template.isActive) return false;

    final occurrenceDate = _dayOnly(date);
    final start = _dayOnly(template.startDate);
    final end = template.endDate != null ? _dayOnly(template.endDate!) : null;

    if (occurrenceDate.isBefore(start)) return false;
    if (end != null && occurrenceDate.isAfter(end)) return false;

    return switch (template.frequency) {
      RecurrenceFrequency.daily => true,
      RecurrenceFrequency.weekly =>
        occurrenceDate.weekday == start.weekday &&
            occurrenceDate.difference(start).inDays % 7 == 0,
      RecurrenceFrequency.monthly =>
        occurrenceDate.day == _resolveMonthlyDay(start, occurrenceDate) &&
            !_monthBeforeStart(start, occurrenceDate),
      RecurrenceFrequency.yearly =>
        occurrenceDate.month == start.month &&
            occurrenceDate.day == _resolveYearlyDay(start, occurrenceDate) &&
            occurrenceDate.year >= start.year,
    };
  }

  List<RecurringTransactionOccurrence> buildOccurrencesInRange(
    Iterable<RecurringTransactionEntity> templates, {
    required DateTime from,
    required DateTime to,
    bool upcomingOnly = false,
  }) {
    final start = _dayOnly(from);
    final end = _dayOnly(to);
    final today = _dayOnly(DateTime.now());
    final occurrences = <RecurringTransactionOccurrence>[];

    for (final template in templates) {
      var current = start;
      while (!current.isAfter(end)) {
        if (upcomingOnly && current.isBefore(today)) {
          current = current.add(const Duration(days: 1));
          continue;
        }
        if (occursOnDate(template, current)) {
          occurrences.add(
            RecurringTransactionOccurrence(template: template, date: current),
          );
        }
        current = current.add(const Duration(days: 1));
      }
    }

    occurrences.sort((a, b) => a.date.compareTo(b.date));
    return occurrences;
  }

  DateTime _dayOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  int _resolveMonthlyDay(DateTime start, DateTime target) {
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    return start.day <= lastDay ? start.day : lastDay;
  }

  int _resolveYearlyDay(DateTime start, DateTime target) {
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    return start.day <= lastDay ? start.day : lastDay;
  }

  bool _monthBeforeStart(DateTime start, DateTime target) {
    final startMonth = DateTime(start.year, start.month);
    final targetMonth = DateTime(target.year, target.month);
    return targetMonth.isBefore(startMonth);
  }
}
