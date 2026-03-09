import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';

class GetTransactionsByCategory
    extends UseCase<List<TransactionEntity>, GetTransactionsByCategoryParams> {
  final TransactionRepository repository;

  GetTransactionsByCategory(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(
    GetTransactionsByCategoryParams params,
  ) {
    return repository.getTransactionsByCategory(params.categoryUuid);
  }
}

class GetTransactionsByCategoryParams extends Equatable {
  final String categoryUuid;

  const GetTransactionsByCategoryParams({required this.categoryUuid});

  @override
  List<Object> get props => [categoryUuid];
}
