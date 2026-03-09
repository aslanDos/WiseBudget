import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

abstract class TransactionRepository {
  /// Get all transactions sorted by date (newest first)
  Future<Either<Failure, List<TransactionEntity>>> getTransactions();

  /// Get transaction by uuid
  Future<Either<Failure, TransactionEntity>> getTransactionById(String uuid);

  /// Get transactions by account uuid
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByAccount(
    String accountUuid,
  );

  /// Get transactions by category uuid
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByCategory(
    String categoryUuid,
  );

  /// Create a new transaction
  Future<Either<Failure, TransactionEntity>> createTransaction(
    TransactionEntity transaction,
  );

  /// Update an existing transaction
  Future<Either<Failure, TransactionEntity>> updateTransaction(
    TransactionEntity transaction,
  );

  /// Delete transaction by uuid
  Future<Either<Failure, void>> deleteTransaction(String uuid);
}
