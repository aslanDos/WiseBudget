import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/transaction/data/data_source/recurring_transaction_local_datasource.dart';
import 'package:wisebuget/features/transaction/data/model/recurring_transaction_model.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/recurring_transaction_repository.dart';

class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  final RecurringTransactionLocalDataSource localDataSource;

  RecurringTransactionRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>>
  getRecurringTransactions() async {
    try {
      final models = await localDataSource.getRecurringTransactions();
      return Right(models.map((item) => item.toEntity()).toList());
    } catch (error) {
      return Left(
        DatabaseFailure('Failed to load recurring transactions: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, RecurringTransactionEntity>>
  createRecurringTransaction(RecurringTransactionEntity transaction) async {
    try {
      final created = await localDataSource.createRecurringTransaction(
        RecurringTransactionModel.fromEntity(transaction),
      );
      return Right(created.toEntity());
    } catch (error) {
      return Left(
        DatabaseFailure('Failed to create recurring transaction: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, RecurringTransactionEntity>>
  updateRecurringTransaction(RecurringTransactionEntity transaction) async {
    try {
      final updated = await localDataSource.updateRecurringTransaction(
        RecurringTransactionModel.fromEntity(transaction),
      );
      return Right(updated.toEntity());
    } catch (error) {
      return Left(
        DatabaseFailure('Failed to update recurring transaction: $error'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecurringTransaction(String uuid) async {
    try {
      await localDataSource.deleteRecurringTransaction(uuid);
      return const Right(null);
    } catch (error) {
      return Left(
        DatabaseFailure('Failed to delete recurring transaction: $error'),
      );
    }
  }
}
