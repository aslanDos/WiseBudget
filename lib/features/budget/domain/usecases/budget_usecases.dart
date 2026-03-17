import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';
import 'package:wisebuget/features/budget/domain/repository/budget_repository.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GetBudgets
// ─────────────────────────────────────────────────────────────────────────────

class GetBudgets extends UseCase<List<BudgetEntity>, GetBudgetsParams> {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  @override
  Future<Either<Failure, List<BudgetEntity>>> call(GetBudgetsParams params) {
    if (params.activeOnly) {
      return repository.getActiveBudgets();
    }
    return repository.getBudgets();
  }
}

class GetBudgetsParams extends Equatable {
  final bool activeOnly;

  const GetBudgetsParams({this.activeOnly = true});

  @override
  List<Object?> get props => [activeOnly];
}

// ─────────────────────────────────────────────────────────────────────────────
// GetBudgetById
// ─────────────────────────────────────────────────────────────────────────────

class GetBudgetById extends UseCase<BudgetEntity, GetBudgetByIdParams> {
  final BudgetRepository repository;

  GetBudgetById(this.repository);

  @override
  Future<Either<Failure, BudgetEntity>> call(GetBudgetByIdParams params) {
    return repository.getBudgetById(params.uuid);
  }
}

class GetBudgetByIdParams extends Equatable {
  final String uuid;

  const GetBudgetByIdParams({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}

// ─────────────────────────────────────────────────────────────────────────────
// CreateBudget
// ─────────────────────────────────────────────────────────────────────────────

class CreateBudget extends UseCase<BudgetEntity, CreateBudgetParams> {
  final BudgetRepository repository;

  CreateBudget(this.repository);

  @override
  Future<Either<Failure, BudgetEntity>> call(CreateBudgetParams params) {
    return repository.createBudget(params.budget);
  }
}

class CreateBudgetParams extends Equatable {
  final BudgetEntity budget;

  const CreateBudgetParams({required this.budget});

  @override
  List<Object?> get props => [budget];
}

// ─────────────────────────────────────────────────────────────────────────────
// UpdateBudget
// ─────────────────────────────────────────────────────────────────────────────

class UpdateBudget extends UseCase<BudgetEntity, UpdateBudgetParams> {
  final BudgetRepository repository;

  UpdateBudget(this.repository);

  @override
  Future<Either<Failure, BudgetEntity>> call(UpdateBudgetParams params) {
    return repository.updateBudget(params.budget);
  }
}

class UpdateBudgetParams extends Equatable {
  final BudgetEntity budget;

  const UpdateBudgetParams({required this.budget});

  @override
  List<Object?> get props => [budget];
}

// ─────────────────────────────────────────────────────────────────────────────
// DeleteBudget
// ─────────────────────────────────────────────────────────────────────────────

class DeleteBudget extends UseCase<void, DeleteBudgetParams> {
  final BudgetRepository repository;

  DeleteBudget(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteBudgetParams params) {
    return repository.deleteBudget(params.uuid);
  }
}

class DeleteBudgetParams extends Equatable {
  final String uuid;

  const DeleteBudgetParams({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}

// ─────────────────────────────────────────────────────────────────────────────
// CalculateBudgetProgress
// ─────────────────────────────────────────────────────────────────────────────

class CalculateBudgetProgress
    extends UseCase<BudgetProgress, CalculateBudgetProgressParams> {
  CalculateBudgetProgress();

  @override
  Future<Either<Failure, BudgetProgress>> call(
    CalculateBudgetProgressParams params,
  ) async {
    try {
      final budget = params.budget;
      final (startDate, endDate) = budget.currentPeriodRange;

      // Filter transactions matching budget criteria
      final matchingTransactions = params.transactions.where((t) {
        // Only expenses count toward budget
        if (t.type != TransactionType.expense) return false;

        // Date range filter
        if (t.date.isBefore(startDate) || t.date.isAfter(endDate)) return false;

        // Category filter (empty = all categories)
        if (budget.categoryUuids.isNotEmpty) {
          if (!budget.categoryUuids.contains(t.categoryUuid)) return false;
        }

        // Account filter (empty = all accounts)
        if (budget.accountUuids.isNotEmpty) {
          if (!budget.accountUuids.contains(t.accountUuid)) return false;
        }

        return true;
      }).toList();

      final totalSpent = matchingTransactions.fold<double>(
        0,
        (sum, t) => sum + t.amount.abs(),
      );

      return Right(BudgetProgress(
        budget: budget,
        spent: totalSpent,
        transactionCount: matchingTransactions.length,
      ));
    } catch (e) {
      return Left(DatabaseFailure('Failed to calculate budget progress: $e'));
    }
  }
}

class CalculateBudgetProgressParams extends Equatable {
  final BudgetEntity budget;
  final List<TransactionEntity> transactions;

  const CalculateBudgetProgressParams({
    required this.budget,
    required this.transactions,
  });

  @override
  List<Object?> get props => [budget, transactions];
}
