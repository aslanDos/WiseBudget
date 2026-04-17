import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final TransactionCubit _transactionCubit;
  final CategoryCubit _categoryCubit;

  AnalyticsCubit({
    required TransactionCubit transactionCubit,
    required CategoryCubit categoryCubit,
  }) : _transactionCubit = transactionCubit,
       _categoryCubit = categoryCubit,
       super(const AnalyticsState());

  // ─────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    emit(state.copyWith(status: CubitStatus.loading));

    await _transactionCubit.loadTransactions();
    if (_categoryCubit.state.categories.isEmpty) {
      await _categoryCubit.loadCategories();
    }

    _recompute();
  }

  void selectPeriod(AnalyticsPeriod period) {
    emit(state.copyWith(selectedPeriod: period));
    _recompute();
  }

  void selectAccount(String? accountUuid) {
    emit(state.copyWith(selectedAccountUuid: () => accountUuid));
    _recompute();
  }

  void selectCategoryType(TransactionType type) {
    emit(state.copyWith(categoryType: type));
    _recompute();
  }

  // ─────────────────────────────────────────────────────────────────────────

  void _recompute() {
    final all = _transactionCubit.state.transactions;
    final period = state.selectedPeriod;
    final accountUuid = state.selectedAccountUuid;

    final filtered = _filterByAccountAndRange(all, accountUuid, period.range);

    emit(
      state.copyWith(
        status: CubitStatus.success,
        barBuckets: _computeBarBuckets(filtered, period),
        categoryBreakdown: _computeCategoryBreakdown(
          filtered,
          state.categoryType,
        ),
      ),
    );
  }

  // ─── Filtering ────────────────────────────────────────────────────────────

  List<TransactionEntity> _filterByAccountAndRange(
    List<TransactionEntity> transactions,
    String? accountUuid,
    DateTimeRange range,
  ) {
    return transactions.where((t) {
      if (accountUuid != null &&
          t.accountUuid != accountUuid &&
          t.toAccountUuid != accountUuid) {
        return false;
      }
      if (t.date.isBefore(range.start)) {
        return false;
      }
      if (t.date.isAfter(range.end)) {
        return false;
      }
      return true;
    }).toList();
  }

  // ─── Bar buckets ──────────────────────────────────────────────────────────

  List<BarBucket> _computeBarBuckets(
    List<TransactionEntity> filtered,
    AnalyticsPeriod period,
  ) {
    return switch (period) {
      TodayPeriod() || YesterdayPeriod() => [],
      ThisWeekPeriod() => _dailyBuckets(
        filtered,
        period.range,
        labelFn: (d) => _weekdayLabel(d),
      ),
      ThisMonthPeriod() || PrevMonthPeriod() => _dailyBuckets(
        filtered,
        period.range,
        labelFn: (d) => '${d.day}',
      ),
      ThisYearPeriod() => _monthlyBuckets(filtered, period.range),
      CustomPeriod() => _customBuckets(filtered, period),
    };
  }

  List<BarBucket> _dailyBuckets(
    List<TransactionEntity> transactions,
    DateTimeRange range, {
    required String Function(DateTime) labelFn,
  }) {
    final buckets = <BarBucket>[];
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
      double income = 0, expense = 0;
      String currency = '';

      for (final t in transactions) {
        if (t.date.isBefore(current) || t.date.isAfter(dayEnd)) {
          continue;
        }
        if (t.isIncome) {
          income += t.amount;
        }
        if (t.isExpense) {
          expense += t.amount;
        }
        if (currency.isEmpty) {
          currency = t.currency;
        }
      }

      buckets.add(
        BarBucket(
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

  List<BarBucket> _monthlyBuckets(
    List<TransactionEntity> transactions,
    DateTimeRange range,
  ) {
    const abbr = [
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

    final buckets = <BarBucket>[];
    var y = range.start.year;
    var m = range.start.month;

    while (y < range.end.year ||
        (y == range.end.year && m <= range.end.month)) {
      final monthStart = DateTime(y, m, 1);
      final monthEnd = DateTime(y, m + 1, 0, 23, 59, 59);
      double income = 0, expense = 0;
      String currency = '';

      for (final t in transactions) {
        if (t.date.isBefore(monthStart) || t.date.isAfter(monthEnd)) {
          continue;
        }
        if (t.isIncome) {
          income += t.amount;
        }
        if (t.isExpense) {
          expense += t.amount;
        }
        if (currency.isEmpty) {
          currency = t.currency;
        }
      }

      buckets.add(
        BarBucket(
          label: abbr[m - 1],
          income: income,
          expense: expense,
          currency: currency,
        ),
      );

      m++;
      if (m > 12) {
        m = 1;
        y++;
      }
    }

    return buckets;
  }

  List<BarBucket> _weeklyBuckets(
    List<TransactionEntity> transactions,
    DateTimeRange range,
  ) {
    const abbr = [
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
    final buckets = <BarBucket>[];
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

      double income = 0, expense = 0;
      String currency = '';

      for (final t in transactions) {
        if (t.date.isBefore(weekStart) || t.date.isAfter(weekEnd)) {
          continue;
        }
        if (t.isIncome) {
          income += t.amount;
        }
        if (t.isExpense) {
          expense += t.amount;
        }
        if (currency.isEmpty) {
          currency = t.currency;
        }
      }

      buckets.add(
        BarBucket(
          label: '${weekStart.day} ${abbr[weekStart.month - 1]}',
          income: income,
          expense: expense,
          currency: currency,
        ),
      );

      weekStart = DateTime(weekStart.year, weekStart.month, weekStart.day + 7);
    }

    return buckets;
  }

  List<BarBucket> _customBuckets(
    List<TransactionEntity> transactions,
    CustomPeriod period,
  ) {
    final days = period.end.difference(period.start).inDays;
    if (days <= 14) {
      return _dailyBuckets(
        transactions,
        period.range,
        labelFn: (d) => '${d.day}',
      );
    }
    if (days <= 90) {
      return _weeklyBuckets(transactions, period.range);
    }
    return _monthlyBuckets(transactions, period.range);
  }

  // ─── Category breakdown ───────────────────────────────────────────────────

  List<CategoryData> _computeCategoryBreakdown(
    List<TransactionEntity> filtered,
    TransactionType type,
  ) {
    final typeFiltered = filtered.where((t) => t.type == type).toList();
    if (typeFiltered.isEmpty) return [];

    final Map<String, double> totals = {};
    String currency = '';

    for (final t in typeFiltered) {
      totals[t.categoryUuid] = (totals[t.categoryUuid] ?? 0) + t.amount;
      if (currency.isEmpty) {
        currency = t.currency;
      }
    }

    final total = totals.values.fold(0.0, (sum, v) => sum + v);
    final categories = _categoryCubit.state.categories;

    final result = totals.entries.map((entry) {
      final category = categories.where((c) => c.uuid == entry.key).firstOrNull;
      return CategoryData(
        categoryUuid: entry.key,
        name: category?.name ?? 'Unknown',
        color: category?.color ?? const Color(AppPalette.defaultCategoryColor),
        icon: category?.icon ?? const IconData(0),
        amount: entry.value,
        currency: currency,
        percentage: total > 0 ? entry.value / total : 0,
      );
    }).toList()..sort((a, b) => b.amount.compareTo(a.amount));

    return result;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _weekdayLabel(DateTime d) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[d.weekday - 1];
  }
}
