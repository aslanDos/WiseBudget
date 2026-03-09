import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';

class UpdateTransaction
    extends UseCase<TransactionEntity, UpdateTransactionParams> {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    UpdateTransactionParams params,
  ) {
    return repository.updateTransaction(params.transaction);
  }
}

class UpdateTransactionParams extends Equatable {
  final TransactionEntity transaction;

  const UpdateTransactionParams({required this.transaction});

  @override
  List<Object> get props => [transaction];
}
