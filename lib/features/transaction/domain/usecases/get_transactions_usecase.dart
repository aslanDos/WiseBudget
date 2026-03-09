import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_repository.dart';

class GetTransactions extends UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) {
    return repository.getTransactions();
  }
}
