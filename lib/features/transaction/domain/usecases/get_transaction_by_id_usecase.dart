import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';

class GetTransactionById
    extends UseCase<TransactionEntity, GetTransactionByIdParams> {
  final TransactionRepository repository;

  GetTransactionById(this.repository);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    GetTransactionByIdParams params,
  ) {
    return repository.getTransactionById(params.uuid);
  }
}

class GetTransactionByIdParams extends Equatable {
  final String uuid;

  const GetTransactionByIdParams({required this.uuid});

  @override
  List<Object> get props => [uuid];
}
