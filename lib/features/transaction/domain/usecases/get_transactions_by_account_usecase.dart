import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';

class GetTransactionsByAccount
    extends UseCase<List<TransactionEntity>, GetTransactionsByAccountParams> {
  final TransactionRepository repository;

  GetTransactionsByAccount(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
    GetTransactionsByAccountParams params,
  ) {
    return repository.getTransactionsByAccount(params.accountUuid);
  }
}

class GetTransactionsByAccountParams extends Equatable {
  final String accountUuid;

  const GetTransactionsByAccountParams({required this.accountUuid});

  @override
  List<Object> get props => [accountUuid];
}
