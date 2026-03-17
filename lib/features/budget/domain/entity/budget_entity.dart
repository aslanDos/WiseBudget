import 'dart:ui';

import 'package:equatable/equatable.dart';

/// Budget period types
enum BudgetPeriod {
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly'),
  custom('custom', 'Custom');

  final String value;
  final String label;

  const BudgetPeriod(this.value, this.label);

  static BudgetPeriod fromString(String value) {
    return BudgetPeriod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BudgetPeriod.monthly,
    );
  }
}

class BudgetEntity extends Equatable {
  final String uuid;
  final String name;
  final double limit;
  final String currency;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> categoryUuids;
  final List<String> accountUuids;
  final String iconCode;
  final int colorValue;
  final DateTime createdDate;
  final bool isArchived;

  /// Validation constants
  static const int maxNameLength = 48;

  const BudgetEntity({
    required this.uuid,
    required this.name,
    required this.limit,
    required this.currency,
    required this.period,
    required this.startDate,
    this.endDate,
    this.categoryUuids = const [],
    this.accountUuids = const [],
    required this.iconCode,
    required this.colorValue,
    required this.createdDate,
    this.isArchived = false,
  });

  /// Validation
  bool get isValid =>
      name.isNotEmpty && name.length <= maxNameLength && limit > 0;

  /// Computed property - returns Color from colorValue
  Color get color => Color(colorValue);

  /// Budget type helpers
  bool get isGlobal => categoryUuids.isEmpty && accountUuids.isEmpty;
  bool get hasCategories => categoryUuids.isNotEmpty;
  bool get hasAccounts => accountUuids.isNotEmpty;
  bool get isSingleCategory => categoryUuids.length == 1;

  /// Current period date range based on period type
  (DateTime start, DateTime end) get currentPeriodRange {
    final now = DateTime.now();
    switch (period) {
      case BudgetPeriod.weekly:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return (
          DateTime(weekStart.year, weekStart.month, weekStart.day),
          DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59),
        );
      case BudgetPeriod.monthly:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (monthStart, monthEnd);
      case BudgetPeriod.custom:
        return (startDate, endDate ?? now);
    }
  }

  /// Total days in current period
  int get daysInPeriod {
    final range = currentPeriodRange;
    return range.$2.difference(range.$1).inDays + 1;
  }

  /// Days elapsed in current period
  int get daysElapsed {
    final range = currentPeriodRange;
    final now = DateTime.now();
    if (now.isBefore(range.$1)) return 0;
    if (now.isAfter(range.$2)) return daysInPeriod;
    return now.difference(range.$1).inDays + 1;
  }

  /// Days remaining in current period
  int get daysRemaining => daysInPeriod - daysElapsed;

  /// Period label for display
  String get periodLabel {
    final range = currentPeriodRange;
    final months = [
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
      'December'
    ];

    switch (period) {
      case BudgetPeriod.monthly:
        return months[range.$1.month - 1];
      case BudgetPeriod.weekly:
        return 'Week ${_weekOfMonth(range.$1)}';
      case BudgetPeriod.custom:
        return '${range.$1.day}/${range.$1.month} - ${range.$2.day}/${range.$2.month}';
    }
  }

  int _weekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final daysDiff = date.difference(firstDayOfMonth).inDays;
    return (daysDiff / 7).floor() + 1;
  }

  BudgetEntity copyWith({
    String? uuid,
    String? name,
    double? limit,
    String? currency,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? categoryUuids,
    List<String>? accountUuids,
    String? iconCode,
    int? colorValue,
    DateTime? createdDate,
    bool? isArchived,
  }) {
    return BudgetEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      limit: limit ?? this.limit,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryUuids: categoryUuids ?? this.categoryUuids,
      accountUuids: accountUuids ?? this.accountUuids,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      createdDate: createdDate ?? this.createdDate,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  List<Object?> get props => [
        uuid,
        name,
        limit,
        currency,
        period,
        startDate,
        endDate,
        categoryUuids,
        accountUuids,
        iconCode,
        colorValue,
        createdDate,
        isArchived,
      ];
}
