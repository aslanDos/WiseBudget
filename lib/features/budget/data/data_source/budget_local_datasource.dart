import 'package:wisebuget/features/budget/data/model/budget_model.dart';

abstract class BudgetLocalDataSource {
  /// Get all budgets
  Future<List<BudgetModel>> getBudgets();

  /// Get all active (non-archived) budgets
  Future<List<BudgetModel>> getActiveBudgets();

  /// Get a budget by UUID
  Future<BudgetModel?> getBudgetById(String uuid);

  /// Create a new budget
  Future<BudgetModel> createBudget(BudgetModel budget);

  /// Update an existing budget
  Future<BudgetModel> updateBudget(BudgetModel budget);

  /// Delete a budget by UUID
  Future<void> deleteBudget(String uuid);
}
