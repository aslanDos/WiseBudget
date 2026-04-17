import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/category_detail_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/usecases/transaction_usecases.dart';

class CategoryDetailCubit extends Cubit<CategoryDetailState> {
  final GetTransactionsByCategory _getTransactionsByCategory;

  CategoryDetailCubit({
    required GetTransactionsByCategory getTransactionsByCategory,
  }) : _getTransactionsByCategory = getTransactionsByCategory,
       super(const CategoryDetailState());

  Future<void> init(CategoryDetailArgs args) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _getTransactionsByCategory(
      GetTransactionsByCategoryParams(categoryUuid: args.categoryUuid),
    );

    result.fold(
      (failure) => emit(state.copyWith(status: CubitStatus.failure)),
      (all) {
        final range = args.period.range;

        // Filter by period range and optional account.
        final filtered = all.where((t) {
          if (args.selectedAccountUuid != null &&
              t.accountUuid != args.selectedAccountUuid) {
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

        final currency = filtered.isNotEmpty ? filtered.first.currency : '';
        final periodTotal = filtered.fold(0.0, (sum, t) => sum + t.amount);

        emit(
          state.copyWith(
            status: CubitStatus.success,
            barBuckets: _computeBarBuckets(filtered, args),
            periodTotal: periodTotal,
            periodCount: filtered.length,
            transactions: filtered,
            currency: currency,
          ),
        );
      },
    );
  }

  // ─── Bucket generation (mirrors AnalyticsCubit logic) ────────────────────

  List<BarBucket> _computeBarBuckets(
    List<TransactionEntity> filtered,
    CategoryDetailArgs args,
  ) {
    final period = args.period;
    final type = args.transactionType;

    return switch (period) {
      TodayPeriod() || YesterdayPeriod() => [],
      ThisWeekPeriod() => _dailyBuckets(
        filtered,
        period.range,
        type,
        labelFn: (d) => _weekdayLabel(d),
      ),
      ThisMonthPeriod() || PrevMonthPeriod() => _dailyBuckets(
        filtered,
        period.range,
        type,
        labelFn: (d) => '${d.day}',
      ),
      ThisYearPeriod() => _monthlyBuckets(filtered, period.range, type),
      CustomPeriod() => _customBuckets(filtered, period, type),
    };
  }

  List<BarBucket> _dailyBuckets(
    List<TransactionEntity> transactions,
    DateTimeRange range,
    TransactionType type, {
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
          income: type == TransactionType.income ? income : 0,
          expense: type == TransactionType.expense ? expense : 0,
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
    TransactionType type,
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
          income: type == TransactionType.income ? income : 0,
          expense: type == TransactionType.expense ? expense : 0,
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
    TransactionType type,
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
          income: type == TransactionType.income ? income : 0,
          expense: type == TransactionType.expense ? expense : 0,
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
    TransactionType type,
  ) {
    final days = period.end.difference(period.start).inDays;
    if (days <= 14) {
      return _dailyBuckets(
        transactions,
        period.range,
        type,
        labelFn: (d) => '${d.day}',
      );
    }
    if (days <= 90) {
      return _weeklyBuckets(transactions, period.range, type);
    }
    return _monthlyBuckets(transactions, period.range, type);
  }

  String _weekdayLabel(DateTime d) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[d.weekday - 1];
  }
}
