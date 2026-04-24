import 'package:equatable/equatable.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';

class BudgetOverview extends Equatable {
  final List<BudgetProgress> budgets;
  final BudgetProgress? totalBudget;
  final List<BudgetInsight> insights;

  const BudgetOverview({
    required this.budgets,
    required this.totalBudget,
    required this.insights,
  });

  @override
  List<Object?> get props => [budgets, totalBudget, insights];
}
