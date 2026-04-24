import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AnalyticsBarBucket extends Equatable {
  final String label;
  final double income;
  final double expense;
  final String currency;

  const AnalyticsBarBucket({
    required this.label,
    required this.income,
    required this.expense,
    required this.currency,
  });

  @override
  List<Object?> get props => [label, income, expense, currency];
}

class AnalyticsCategoryBreakdown extends Equatable {
  final String categoryUuid;
  final String name;
  final Color color;
  final IconData icon;
  final double amount;
  final String currency;
  final double percentage;

  const AnalyticsCategoryBreakdown({
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

class AnalyticsReport extends Equatable {
  final List<AnalyticsBarBucket> barBuckets;
  final List<AnalyticsCategoryBreakdown> categoryBreakdown;
  final double totalIncome;
  final double totalExpense;
  final String currency;

  const AnalyticsReport({
    required this.barBuckets,
    required this.categoryBreakdown,
    required this.totalIncome,
    required this.totalExpense,
    required this.currency,
  });

  @override
  List<Object?> get props => [
    barBuckets,
    categoryBreakdown,
    totalIncome,
    totalExpense,
    currency,
  ];
}
