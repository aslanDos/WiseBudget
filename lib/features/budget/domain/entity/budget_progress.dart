import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';

import 'budget_entity.dart';

/// Status of budget progress
enum BudgetProgressStatus {
  onTrack,
  nearLimit,
  exceeded,
}

/// Computed budget progress - NOT stored, calculated at runtime
class BudgetProgress extends Equatable {
  final BudgetEntity budget;
  final double spent;
  final int transactionCount;

  const BudgetProgress({
    required this.budget,
    required this.spent,
    required this.transactionCount,
  });

  /// Remaining amount
  double get remaining => budget.limit - spent;

  /// Progress as a ratio (0.0 to 1.0+)
  double get progress => budget.limit > 0 ? spent / budget.limit : 0;

  /// Progress as percentage (0-100+)
  double get progressPercent => progress * 100;

  /// Whether budget is exceeded
  bool get isExceeded => spent > budget.limit;

  /// Whether budget is near limit (80%+)
  bool get isNearLimit => progress >= 0.8 && !isExceeded;

  /// Whether budget is on track (<80%)
  bool get isOnTrack => progress < 0.8;

  /// Current status
  BudgetProgressStatus get status {
    if (isExceeded) return BudgetProgressStatus.exceeded;
    if (isNearLimit) return BudgetProgressStatus.nearLimit;
    return BudgetProgressStatus.onTrack;
  }

  /// Amount over budget (0 if not exceeded)
  double get overBy => isExceeded ? spent - budget.limit : 0;

  /// Daily average spending
  double get dailyAverage =>
      budget.daysElapsed > 0 ? spent / budget.daysElapsed : 0;

  /// Projected total at current pace
  double get projectedTotal => dailyAverage * budget.daysInPeriod;

  /// Whether projected to exceed budget
  bool get isProjectedToExceed => projectedTotal > budget.limit;

  /// Daily budget to stay on track
  double get dailyBudget =>
      budget.daysRemaining > 0 ? remaining / budget.daysRemaining : 0;

  /// Money value objects for display
  Money get spentMoney => Money(spent, budget.currency);
  Money get limitMoney => Money(budget.limit, budget.currency);
  Money get remainingMoney => Money(remaining.abs(), budget.currency);
  Money get overByMoney => Money(overBy, budget.currency);
  Money get dailyBudgetMoney => Money(dailyBudget.abs(), budget.currency);
  Money get projectedMoney => Money(projectedTotal, budget.currency);

  @override
  List<Object?> get props => [budget, spent, transactionCount];
}

/// Insight types for budget suggestions/warnings
enum BudgetInsightType {
  warning,
  suggestion,
  info,
}

/// Budget insight for suggestions and warnings
class BudgetInsight extends Equatable {
  final BudgetInsightType type;
  final String title;
  final String description;
  final String? budgetUuid;

  const BudgetInsight({
    required this.type,
    required this.title,
    required this.description,
    this.budgetUuid,
  });

  @override
  List<Object?> get props => [type, title, description, budgetUuid];
}
