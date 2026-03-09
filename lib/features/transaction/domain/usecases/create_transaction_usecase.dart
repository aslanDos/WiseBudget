import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';

class CreateTransaction
    extends UseCase<TransactionEntity, CreateTransactionParams> {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    CreateTransactionParams params,
  ) {
    return repository.createTransaction(params.transaction);
  }
}

class CreateTransactionParams extends Equatable {
  final TransactionEntity transaction;

  const CreateTransactionParams({required this.transaction});

  @override
  List<Object> get props => [transaction];
}
