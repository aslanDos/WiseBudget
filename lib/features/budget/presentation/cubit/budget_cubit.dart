import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';
import 'package:wisebuget/features/budget/domain/usecases/budget_usecases.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_state.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final GetBudgets _getBudgets;
  final CreateBudget _createBudget;
  final UpdateBudget _updateBudget;
  final DeleteBudget _deleteBudget;
  final CalculateBudgetProgress _calculateProgress;
  final TransactionCubit _transactionCubit;

  final _log = Logger('BudgetCubit');

  BudgetCubit({
    required GetBudgets getBudgets,
    required CreateBudget createBudget,
    required UpdateBudget updateBudget,
    required DeleteBudget deleteBudget,
    required CalculateBudgetProgress calculateProgress,
    required TransactionCubit transactionCubit,
  })  : _getBudgets = getBudgets,
        _createBudget = createBudget,
        _updateBudget = updateBudget,
        _deleteBudget = deleteBudget,
        _calculateProgress = calculateProgress,
        _transactionCubit = transactionCubit,
        super(const BudgetState());

  /// Load all active budgets and calculate progress
  Future<void> loadBudgets() async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _getBudgets(const GetBudgetsParams(activeOnly: true));

    result.fold(
      (failure) {
        _log.warning('Failed to load budgets: ${failure.message}');
        emit(state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (budgets) async {
        // Calculate progress for each budget
        final progressList = await _calculateProgressForBudgets(budgets);
        final insights = _generateInsights(progressList);
        final total = _calculateTotalBudget(progressList);

        emit(state.copyWith(
          status: CubitStatus.success,
          budgets: progressList,
          totalBudget: total,
          insights: insights,
        ));
      },
    );
  }

  /// Calculate progress for all budgets
  Future<List<BudgetProgress>> _calculateProgressForBudgets(
    List<BudgetEntity> budgets,
  ) async {
    final transactions = _transactionCubit.state.transactions;
    final progressList = <BudgetProgress>[];

    for (final budget in budgets) {
      final result = await _calculateProgress(
        CalculateBudgetProgressParams(
          budget: budget,
          transactions: transactions,
        ),
      );

      result.fold(
        (failure) =>
            _log.warning('Failed to calculate progress: ${failure.message}'),
        (progress) => progressList.add(progress),
      );
    }

    return progressList;
  }

  /// Calculate aggregated total budget from all budgets
  BudgetProgress? _calculateTotalBudget(List<BudgetProgress> budgets) {
    if (budgets.isEmpty) return null;

    final totalLimit = budgets.fold<double>(0, (sum, b) => sum + b.budget.limit);
    final totalSpent = budgets.fold<double>(0, (sum, b) => sum + b.spent);
    final totalTransactions =
        budgets.fold<int>(0, (sum, b) => sum + b.transactionCount);

    // Create a virtual "total" budget entity
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

  /// Generate insights based on budget progress
  List<BudgetInsight> _generateInsights(List<BudgetProgress> budgets) {
    final insights = <BudgetInsight>[];

    for (final progress in budgets) {
      // Exceeded budget warning
      if (progress.isExceeded) {
        insights.add(BudgetInsight(
          type: BudgetInsightType.warning,
          title: '${progress.budget.name} exceeded',
          description:
              'Over by ${progress.overByMoney.formatted}. Consider adjusting your limit.',
          budgetUuid: progress.budget.uuid,
        ));
      }
      // Projected overspend suggestion
      else if (progress.isProjectedToExceed && progress.budget.daysRemaining > 3) {
        insights.add(BudgetInsight(
          type: BudgetInsightType.suggestion,
          title: 'Projected overspend',
          description:
              'At current pace, ${progress.budget.name} will reach ${progress.projectedMoney.formatted}',
          budgetUuid: progress.budget.uuid,
        ));
      }
    }

    return insights;
  }

  /// Add a new budget
  Future<void> addBudget(BudgetEntity budget) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _createBudget(CreateBudgetParams(budget: budget));

    result.fold(
      (failure) {
        _log.warning('Failed to create budget: ${failure.message}');
        emit(state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) => emit(state.copyWith(status: CubitStatus.success)),
    );
  }

  /// Edit an existing budget
  Future<void> editBudget(BudgetEntity budget) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _updateBudget(UpdateBudgetParams(budget: budget));

    result.fold(
      (failure) {
        _log.warning('Failed to update budget: ${failure.message}');
        emit(state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) => emit(state.copyWith(status: CubitStatus.success)),
    );
  }

  /// Archive a budget (soft delete)
  Future<void> archiveBudget(String uuid) async {
    final budgetProgress = state.budgets.firstWhere(
      (b) => b.budget.uuid == uuid,
      orElse: () => throw Exception('Budget not found'),
    );
    await editBudget(budgetProgress.budget.copyWith(isArchived: true));
  }

  /// Delete a budget permanently
  Future<void> deleteBudget(String uuid) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _deleteBudget(DeleteBudgetParams(uuid: uuid));

    result.fold(
      (failure) {
        _log.warning('Failed to delete budget: ${failure.message}');
        emit(state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) => emit(state.copyWith(status: CubitStatus.success)),
    );
  }

  /// Called when transactions change - recalculate progress
  void onTransactionsChanged() {
    if (state.status == CubitStatus.success) {
      loadBudgets();
    }
  }
}
