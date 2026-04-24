import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_overview.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';
import 'package:wisebuget/features/budget/domain/usecases/budget_usecases.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class BuildBudgetOverview
    extends UseCase<BudgetOverview, BuildBudgetOverviewParams> {
  final CalculateBudgetProgress _calculateBudgetProgress;

  BuildBudgetOverview(this._calculateBudgetProgress);

  @override
  Future<Either<Failure, BudgetOverview>> call(
    BuildBudgetOverviewParams params,
  ) async {
    try {
      final progressList = <BudgetProgress>[];

      for (final budget in params.budgets) {
        final result = await _calculateBudgetProgress(
          CalculateBudgetProgressParams(
            budget: budget,
            transactions: params.transactions,
          ),
        );

        result.fold((failure) => throw failure, progressList.add);
      }

      return Right(
        BudgetOverview(
          budgets: progressList,
          totalBudget: _calculateTotalBudget(progressList),
          insights: _generateInsights(progressList),
        ),
      );
    } catch (error) {
      if (error is Failure) return Left(error);
      return Left(DatabaseFailure('Failed to build budget overview: $error'));
    }
  }

  BudgetProgress? _calculateTotalBudget(List<BudgetProgress> budgets) {
    if (budgets.isEmpty) return null;

    final totalLimit = budgets.fold<double>(
      0,
      (sum, item) => sum + item.budget.limit,
    );
    final totalSpent = budgets.fold<double>(0, (sum, item) => sum + item.spent);
    final totalTransactions = budgets.fold<int>(
      0,
      (sum, item) => sum + item.transactionCount,
    );

    final totalBudgetEntity = BudgetEntity(
      uuid: 'total',
      name: 'Total Budget',
      limit: totalLimit,
      currency: budgets.first.budget.currency,
      period: BudgetPeriod.monthly,
      startDate: DateTime.now(),
      categoryUuids: const [],
      accountUuids: const [],
      iconCode: 'wallet',
      colorValue: 0xFF6366F1,
      createdDate: DateTime.now(),
    );

    return BudgetProgress(
      budget: totalBudgetEntity,
      spent: totalSpent,
      transactionCount: totalTransactions,
    );
  }

  List<BudgetInsight> _generateInsights(List<BudgetProgress> budgets) {
    final insights = <BudgetInsight>[];

    for (final progress in budgets) {
      if (progress.isExceeded) {
        insights.add(
          BudgetInsight(
            type: BudgetInsightType.warning,
            title: '${progress.budget.name} exceeded',
            description:
                'Over by ${progress.overByMoney.formatted}. Consider adjusting your limit.',
            budgetUuid: progress.budget.uuid,
          ),
        );
      } else if (progress.isProjectedToExceed &&
          progress.budget.daysRemaining > 3) {
        insights.add(
          BudgetInsight(
            type: BudgetInsightType.suggestion,
            title: 'Projected overspend',
            description:
                'At current pace, ${progress.budget.name} will reach ${progress.projectedMoney.formatted}',
            budgetUuid: progress.budget.uuid,
          ),
        );
      }
    }

    return insights;
  }
}

class BuildBudgetOverviewParams extends Equatable {
  final List<BudgetEntity> budgets;
  final List<TransactionEntity> transactions;

  const BuildBudgetOverviewParams({
    required this.budgets,
    required this.transactions,
  });

  @override
  List<Object?> get props => [budgets, transactions];
}
