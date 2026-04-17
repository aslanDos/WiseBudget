import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class CategoryDetailArgs {
  final String categoryUuid;
  final String categoryName;
  final Color categoryColor;
  final IconData categoryIcon;
  final TransactionType transactionType;
  final AnalyticsPeriod period;
  final String? selectedAccountUuid;

  const CategoryDetailArgs({
    required this.categoryUuid,
    required this.categoryName,
    required this.categoryColor,
    required this.categoryIcon,
    required this.transactionType,
    required this.period,
    this.selectedAccountUuid,
  });
}

class CategoryDetailState extends Equatable {
  final CubitStatus status;

  /// Bar chart buckets for the selected period. Empty for single-day periods.
  final List<BarBucket> barBuckets;

  /// Stats for the selected period.
  final double periodTotal;
  final int periodCount;

  /// Transactions filtered to the selected period, sorted newest first.
  final List<TransactionEntity> transactions;
  final String currency;

  const CategoryDetailState({
    this.status = CubitStatus.initial,
    this.barBuckets = const [],
    this.periodTotal = 0,
    this.periodCount = 0,
    this.transactions = const [],
    this.currency = '',
  });

  CategoryDetailState copyWith({
    CubitStatus? status,
    List<BarBucket>? barBuckets,
    double? periodTotal,
    int? periodCount,
    List<TransactionEntity>? transactions,
    String? currency,
  }) {
    return CategoryDetailState(
      status: status ?? this.status,
      barBuckets: barBuckets ?? this.barBuckets,
      periodTotal: periodTotal ?? this.periodTotal,
      periodCount: periodCount ?? this.periodCount,
      transactions: transactions ?? this.transactions,
      currency: currency ?? this.currency,
    );
  }

  @override
  List<Object?> get props => [
    status,
    barBuckets,
    periodTotal,
    periodCount,
    transactions,
    currency,
  ];
}
