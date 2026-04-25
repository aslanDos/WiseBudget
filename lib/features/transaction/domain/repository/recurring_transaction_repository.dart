import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';

abstract class RecurringTransactionRepository {
  Future<Either<Failure, List<RecurringTransactionEntity>>>
  getRecurringTransactions();

  Future<Either<Failure, RecurringTransactionEntity>>
  createRecurringTransaction(RecurringTransactionEntity transaction);

  Future<Either<Failure, RecurringTransactionEntity>>
  updateRecurringTransaction(RecurringTransactionEntity transaction);

  Future<Either<Failure, void>> deleteRecurringTransaction(String uuid);
}
