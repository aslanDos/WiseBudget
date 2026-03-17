import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/budget/data/data_source/budget_local_datasource.dart';
import 'package:wisebuget/features/budget/data/model/budget_model.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/domain/repository/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<BudgetEntity>>> getBudgets() async {
    try {
      final models = await localDataSource.getBudgets();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get budgets: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BudgetEntity>>> getActiveBudgets() async {
    try {
      final models = await localDataSource.getActiveBudgets();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active budgets: $e'));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> getBudgetById(String uuid) async {
    try {
      final model = await localDataSource.getBudgetById(uuid);
      if (model == null) {
        return Left(NotFoundFailure('Budget not found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get budget: $e'));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> createBudget(
      BudgetEntity budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final created = await localDataSource.createBudget(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to create budget: $e'));
    }
  }

  @override
  Future<Either<Failure, BudgetEntity>> updateBudget(
      BudgetEntity budget) async {
    try {
      final model = BudgetModel.fromEntity(budget);
      final updated = await localDataSource.updateBudget(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to update budget: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String uuid) async {
    try {
      await localDataSource.deleteBudget(uuid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete budget: $e'));
    }
  }
}
