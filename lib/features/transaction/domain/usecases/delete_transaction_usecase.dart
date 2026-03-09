import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';

class DeleteTransaction extends UseCase<void, DeleteTransactionParams> {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTransactionParams params) {
    return repository.deleteTransaction(params.uuid);
  }
}

class DeleteTransactionParams extends Equatable {
  final String uuid;

  const DeleteTransactionParams({required this.uuid});

  @override
  List<Object> get props => [uuid];
}
