import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/transaction/data/data_source/transaction_local_datasource.dart';
import 'package:wisebuget/features/transaction/data/model/transaction_model.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions() async {
    try {
      final models = await localDataSource.getTransactions();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> getTransactionById(
    String uuid,
  ) async {
    try {
      final model = await localDataSource.getTransactionByUuid(uuid);
      if (model == null) {
        return Left(NotFoundFailure('Transaction not found: $uuid'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByAccount(
    String accountUuid,
  ) async {
    try {
      final models =
          await localDataSource.getTransactionsByAccountUuid(accountUuid);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get transactions by account: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCategory(
    String categoryUuid,
  ) async {
    try {
      final models =
          await localDataSource.getTransactionsByCategoryUuid(categoryUuid);
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get transactions by category: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final created = await localDataSource.createTransaction(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to create transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final updated = await localDataSource.updateTransaction(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to update transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String uuid) async {
    try {
      await localDataSource.deleteTransaction(uuid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete transaction: $e'));
    }
  }
}
