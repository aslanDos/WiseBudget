import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/domain/usecases/build_budget_overview.dart';
import 'package:wisebuget/features/budget/domain/usecases/budget_usecases.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_state.dart';
import 'package:wisebuget/features/transaction/domain/usecases/transaction_usecases.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final GetBudgets _getBudgets;
  final GetTransactions _getTransactions;
  final CreateBudget _createBudget;
  final UpdateBudget _updateBudget;
  final DeleteBudget _deleteBudget;
  final BuildBudgetOverview _buildOverview;

  final _log = Logger('BudgetCubit');

  BudgetCubit({
    required GetBudgets getBudgets,
    required GetTransactions getTransactions,
    required CreateBudget createBudget,
    required UpdateBudget updateBudget,
    required DeleteBudget deleteBudget,
    required BuildBudgetOverview buildOverview,
  }) : _getBudgets = getBudgets,
       _getTransactions = getTransactions,
       _createBudget = createBudget,
       _updateBudget = updateBudget,
       _deleteBudget = deleteBudget,
       _buildOverview = buildOverview,
       super(const BudgetState());

  /// Load all active budgets and calculate progress
  Future<void> loadBudgets() async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _getBudgets(const GetBudgetsParams(activeOnly: true));

    result.fold(
      (failure) {
        _log.warning('Failed to load budgets: ${failure.message}');
        emit(
          state.copyWith(
            status: CubitStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (budgets) async {
        final transactionsResult = await _getTransactions(const NoParams());
        await transactionsResult.fold(
          (failure) async {
            _log.warning('Failed to load transactions: ${failure.message}');
            emit(
              state.copyWith(
                status: CubitStatus.failure,
                errorMessage: failure.message,
              ),
            );
          },
          (transactions) async {
            final overviewResult = await _buildOverview(
              BuildBudgetOverviewParams(
                budgets: budgets,
                transactions: transactions,
              ),
            );

            overviewResult.fold(
              (failure) {
                _log.warning(
                  'Failed to build budget overview: ${failure.message}',
                );
                emit(
                  state.copyWith(
                    status: CubitStatus.failure,
                    errorMessage: failure.message,
                  ),
                );
              },
              (overview) {
                emit(
                  state.copyWith(
                    status: CubitStatus.success,
                    budgets: overview.budgets,
                    totalBudget: overview.totalBudget,
                    insights: overview.insights,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Add a new budget
  Future<void> addBudget(BudgetEntity budget) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _createBudget(CreateBudgetParams(budget: budget));

    result.fold((failure) {
      _log.warning('Failed to create budget: ${failure.message}');
      emit(
        state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }, (_) => emit(state.copyWith(status: CubitStatus.success)));
  }

  /// Edit an existing budget
  Future<void> editBudget(BudgetEntity budget) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _updateBudget(UpdateBudgetParams(budget: budget));

    result.fold((failure) {
      _log.warning('Failed to update budget: ${failure.message}');
      emit(
        state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }, (_) => emit(state.copyWith(status: CubitStatus.success)));
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

    result.fold((failure) {
      _log.warning('Failed to delete budget: ${failure.message}');
      emit(
        state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ),
      );
    }, (_) => emit(state.copyWith(status: CubitStatus.success)));
  }

  /// Called when transactions change - recalculate progress
  void onTransactionsChanged() {
    if (state.status == CubitStatus.success) {
      loadBudgets();
    }
  }
}
