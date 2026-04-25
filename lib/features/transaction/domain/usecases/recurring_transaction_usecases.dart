import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/recurring_transaction_repository.dart';

class GetRecurringTransactions
    extends UseCase<List<RecurringTransactionEntity>, NoParams> {
  final RecurringTransactionRepository repository;

  GetRecurringTransactions(this.repository);

  @override
  Future<Either<Failure, List<RecurringTransactionEntity>>> call(
    NoParams params,
  ) {
    return repository.getRecurringTransactions();
  }
}

class CreateRecurringTransaction
    extends
        UseCase<RecurringTransactionEntity, CreateRecurringTransactionParams> {
  final RecurringTransactionRepository repository;

  CreateRecurringTransaction(this.repository);

  @override
  Future<Either<Failure, RecurringTransactionEntity>> call(
    CreateRecurringTransactionParams params,
  ) {
    return repository.createRecurringTransaction(params.transaction);
  }
}

class UpdateRecurringTransaction
    extends
        UseCase<RecurringTransactionEntity, UpdateRecurringTransactionParams> {
  final RecurringTransactionRepository repository;

  UpdateRecurringTransaction(this.repository);

  @override
  Future<Either<Failure, RecurringTransactionEntity>> call(
    UpdateRecurringTransactionParams params,
  ) {
    return repository.updateRecurringTransaction(params.transaction);
  }
}

class DeleteRecurringTransaction
    extends UseCase<void, DeleteRecurringTransactionParams> {
  final RecurringTransactionRepository repository;

  DeleteRecurringTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteRecurringTransactionParams params) {
    return repository.deleteRecurringTransaction(params.uuid);
  }
}

class CreateRecurringTransactionParams {
  final RecurringTransactionEntity transaction;

  CreateRecurringTransactionParams({required this.transaction});
}

class UpdateRecurringTransactionParams {
  final RecurringTransactionEntity transaction;

  UpdateRecurringTransactionParams({required this.transaction});
}

class DeleteRecurringTransactionParams {
  final String uuid;

  DeleteRecurringTransactionParams({required this.uuid});
}
