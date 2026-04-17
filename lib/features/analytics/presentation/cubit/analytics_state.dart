import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';

/// A single bucket in the bar chart — label is pre-computed (e.g. "Mon", "15", "Jan").
class BarBucket extends Equatable {
  final String label;
  final double income;
  final double expense;
  final String currency;

  const BarBucket({
    required this.label,
    required this.income,
    required this.expense,
    required this.currency,
  });

  double get net => income - expense;

  @override
  List<Object?> get props => [label, income, expense, currency];
}

class CategoryData extends Equatable {
  final String categoryUuid;
  final String name;
  final Color color;
  final IconData icon;
  final double amount;
  final String currency;

  /// 0.0–1.0 share of total for this type
  final double percentage;

  const CategoryData({
    required this.categoryUuid,
    required this.name,
    required this.color,
    required this.icon,
    required this.amount,
    required this.currency,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryUuid, amount, percentage];
}

class AnalyticsState extends Equatable {
  final CubitStatus status;
  final AnalyticsPeriod selectedPeriod;
  final String? selectedAccountUuid;

  /// Bar chart buckets for [selectedPeriod]. Empty for single-day periods.
  final List<BarBucket> barBuckets;

  /// Category breakdown for [categoryType] within [selectedPeriod].
  final List<CategoryData> categoryBreakdown;

  /// Whether to show expense or income category breakdown.
  final TransactionType categoryType;

  final String? errorMessage;

  const AnalyticsState({
    this.status = CubitStatus.initial,
    this.selectedPeriod = const ThisMonthPeriod(),
    this.selectedAccountUuid,
    this.barBuckets = const [],
    this.categoryBreakdown = const [],
    this.categoryType = TransactionType.expense,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    CubitStatus? status,
    AnalyticsPeriod? selectedPeriod,
    String? Function()? selectedAccountUuid,
    List<BarBucket>? barBuckets,
    List<CategoryData>? categoryBreakdown,
    TransactionType? categoryType,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      selectedAccountUuid: selectedAccountUuid != null
          ? selectedAccountUuid()
          : this.selectedAccountUuid,
      barBuckets: barBuckets ?? this.barBuckets,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      categoryType: categoryType ?? this.categoryType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedPeriod,
    selectedAccountUuid,
    barBuckets,
    categoryBreakdown,
    categoryType,
    errorMessage,
  ];
}
