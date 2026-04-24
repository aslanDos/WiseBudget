import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';
import 'package:wisebuget/features/analytics/domain/entity/analytics_report.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class BuildAnalyticsReport {
  const BuildAnalyticsReport();

  AnalyticsReport call({
    required List<TransactionEntity> transactions,
    required List<CategoryEntity> categories,
    required AnalyticsPeriod period,
    required TransactionType categoryType,
    required String currency,
    String? selectedAccountUuid,
  }) {
    final filtered = _filterByAccountAndRange(
      transactions,
      selectedAccountUuid,
      period.range,
    );

    double totalIncome = 0;
    double totalExpense = 0;
    for (final transaction in filtered) {
      if (transaction.isIncome) totalIncome += transaction.amountInBase;
      if (transaction.isExpense) totalExpense += transaction.amountInBase;
    }

    return AnalyticsReport(
      barBuckets: _computeBarBuckets(filtered, period, currency),
      categoryBreakdown: _computeCategoryBreakdown(
        filtered,
        categories,
        categoryType,
        currency,
      ),
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      currency: currency,
    );
  }

  List<TransactionEntity> _filterByAccountAndRange(
    List<TransactionEntity> transactions,
    String? accountUuid,
    DateTimeRange range,
  ) {
    return transactions.where((transaction) {
      if (accountUuid != null &&
          transaction.accountUuid != accountUuid &&
          transaction.toAccountUuid != accountUuid) {
        return false;
      }
      if (transaction.date.isBefore(range.start)) return false;
      if (transaction.date.isAfter(range.end)) return false;
      return true;
    }).toList();
  }

  List<AnalyticsBarBucket> _computeBarBuckets(
    List<TransactionEntity> filtered,
    AnalyticsPeriod period,
    String currency,
  ) {
    return switch (period) {
      TodayPeriod() || YesterdayPeriod() => const [],
      ThisWeekPeriod() => _dailyBuckets(
        filtered,
        period.range,
        currency: currency,
        labelFn: _weekdayLabel,
      ),
      ThisMonthPeriod() || PrevMonthPeriod() => _dailyBuckets(
        filtered,
        period.range,
        currency: currency,
        labelFn: (date) => '${date.day}',
      ),
      ThisYearPeriod() => _monthlyBuckets(filtered, period.range, currency),
      CustomPeriod() => _customBuckets(filtered, period, currency),
    };
  }

  List<AnalyticsBarBucket> _dailyBuckets(
    List<TransactionEntity> transactions,
    DateTimeRange range, {
    required String currency,
    required String Function(DateTime) labelFn,
  }) {
    final buckets = <AnalyticsBarBucket>[];
    var current = range.start;

    while (!current.isAfter(range.end)) {
      final dayEnd = DateTime(
        current.year,
        current.month,
        current.day,
        23,
        59,
        59,
      );
      double income = 0;
      double expense = 0;

      for (final transaction in transactions) {
        if (transaction.date.isBefore(current) ||
            transaction.date.isAfter(dayEnd)) {
          continue;
        }
        if (transaction.isIncome) income += transaction.amountInBase;
        if (transaction.isExpense) expense += transaction.amountInBase;
      }

      buckets.add(
        AnalyticsBarBucket(
          label: labelFn(current),
          income: income,
          expense: expense,
          currency: currency,
        ),
      );
      current = DateTime(current.year, current.month, current.day + 1);
    }

    return buckets;
  }

  List<AnalyticsBarBucket> _monthlyBuckets(
    List<TransactionEntity> transactions,
    DateTimeRange range,
    String currency,
  ) {
    const abbreviations = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final buckets = <AnalyticsBarBucket>[];
    var year = range.start.year;
    var month = range.start.month;

    while (year < range.end.year ||
        (year == range.end.year && month <= range.end.month)) {
      final monthStart = DateTime(year, month, 1);
      final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);
      double income = 0;
      double expense = 0;

      for (final transaction in transactions) {
        if (transaction.date.isBefore(monthStart) ||
            transaction.date.isAfter(monthEnd)) {
          continue;
        }
        if (transaction.isIncome) income += transaction.amountInBase;
        if (transaction.isExpense) expense += transaction.amountInBase;
      }

      buckets.add(
        AnalyticsBarBucket(
          label: abbreviations[month - 1],
          income: income,
          expense: expense,
          currency: currency,
        ),
      );

      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    return buckets;
  }

  List<AnalyticsBarBucket> _weeklyBuckets(
    List<TransactionEntity> transactions,
    DateTimeRange range,
    String currency,
  ) {
    const abbreviations = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final buckets = <AnalyticsBarBucket>[];
    var weekStart = range.start;

    while (!weekStart.isAfter(range.end)) {
      final rawEnd = weekStart.add(const Duration(days: 6));
      final effectiveEnd = rawEnd.isAfter(range.end) ? range.end : rawEnd;
      final weekEnd = DateTime(
        effectiveEnd.year,
        effectiveEnd.month,
        effectiveEnd.day,
        23,
        59,
        59,
      );
      double income = 0;
      double expense = 0;

      for (final transaction in transactions) {
        if (transaction.date.isBefore(weekStart) ||
            transaction.date.isAfter(weekEnd)) {
          continue;
        }
        if (transaction.isIncome) income += transaction.amountInBase;
        if (transaction.isExpense) expense += transaction.amountInBase;
      }

      buckets.add(
        AnalyticsBarBucket(
          label: '${weekStart.day} ${abbreviations[weekStart.month - 1]}',
          income: income,
          expense: expense,
          currency: currency,
        ),
      );
      weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day + 7);
    }

    return buckets;
  }

  List<AnalyticsBarBucket> _customBuckets(
    List<TransactionEntity> transactions,
    CustomPeriod period,
    String currency,
  ) {
    final days = period.end.difference(period.start).inDays;
    if (days <= 14) {
      return _dailyBuckets(
        transactions,
        period.range,
        currency: currency,
        labelFn: (date) => '${date.day}',
      );
    }
    if (days <= 90) {
      return _weeklyBuckets(transactions, period.range, currency);
    }
    return _monthlyBuckets(transactions, period.range, currency);
  }

  List<AnalyticsCategoryBreakdown> _computeCategoryBreakdown(
    List<TransactionEntity> filtered,
    List<CategoryEntity> categories,
    TransactionType type,
    String currency,
  ) {
    final typeFiltered = filtered.where(
      (transaction) => transaction.type == type,
    );
    if (typeFiltered.isEmpty) return const [];

    final totals = <String, double>{};
    for (final transaction in typeFiltered) {
      totals[transaction.categoryUuid] =
          (totals[transaction.categoryUuid] ?? 0) + transaction.amountInBase;
    }

    final totalAmount = totals.values.fold(0.0, (sum, value) => sum + value);
    final result = totals.entries.map((entry) {
      final category = categories
          .where((item) => item.uuid == entry.key)
          .firstOrNull;
      return AnalyticsCategoryBreakdown(
        categoryUuid: entry.key,
        name: category?.name ?? 'Unknown',
        color: category?.color ?? const Color(AppPalette.defaultCategoryColor),
        icon: category?.icon ?? const IconData(0),
        amount: entry.value,
        currency: currency,
        percentage: totalAmount > 0 ? entry.value / totalAmount : 0,
      );
    }).toList()..sort((left, right) => right.amount.compareTo(left.amount));

    return result;
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[date.weekday - 1];
  }
}
