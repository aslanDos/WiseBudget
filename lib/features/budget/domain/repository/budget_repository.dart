import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';

abstract class BudgetRepository {
  /// Get all budgets
  Future<Either<Failure, List<BudgetEntity>>> getBudgets();

  /// Get all active (non-archived) budgets
  Future<Either<Failure, List<BudgetEntity>>> getActiveBudgets();

  /// Get a budget by UUID
  Future<Either<Failure, BudgetEntity>> getBudgetById(String uuid);

  /// Create a new budget
  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity budget);

  /// Update an existing budget
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity budget);

  /// Delete a budget by UUID
  Future<Either<Failure, void>> deleteBudget(String uuid);
}
