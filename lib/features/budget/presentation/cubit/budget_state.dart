import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';

class BudgetState extends Equatable {
  final CubitStatus status;
  final List<BudgetProgress> budgets;
  final BudgetProgress? totalBudget;
  final List<BudgetInsight> insights;
  final String? errorMessage;

  const BudgetState({
    this.status = CubitStatus.initial,
    this.budgets = const [],
    this.totalBudget,
    this.insights = const [],
    this.errorMessage,
  });

  /// Budgets sorted by status: exceeded first, then near limit, then on track
  List<BudgetProgress> get sortedBudgets {
    final sorted = List<BudgetProgress>.from(budgets);
    sorted.sort((a, b) {
      final statusOrder = {
        BudgetProgressStatus.exceeded: 0,
        BudgetProgressStatus.nearLimit: 1,
        BudgetProgressStatus.onTrack: 2,
      };
      return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
    });
    return sorted;
  }

  /// Number of exceeded budgets
  int get exceededCount =>
      budgets.where((b) => b.status == BudgetProgressStatus.exceeded).length;

  /// Number of near limit budgets
  int get nearLimitCount =>
      budgets.where((b) => b.status == BudgetProgressStatus.nearLimit).length;

  /// Whether there are any budgets
  bool get hasBudgets => budgets.isNotEmpty;

  /// Whether there are any insights
  bool get hasInsights => insights.isNotEmpty;

  BudgetState copyWith({
    CubitStatus? status,
    List<BudgetProgress>? budgets,
    BudgetProgress? totalBudget,
    List<BudgetInsight>? insights,
    String? errorMessage,
  }) {
    return BudgetState(
      status: status ?? this.status,
      budgets: budgets ?? this.budgets,
      totalBudget: totalBudget ?? this.totalBudget,
      insights: insights ?? this.insights,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, budgets, totalBudget, insights, errorMessage];
}
