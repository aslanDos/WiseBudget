import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';

class GetAccounts extends UseCase<List<AccountEntity>, NoParams> {
  final AccountRepository repository;

  GetAccounts(this.repository);

  @override
  Future<Either<Failure, List<AccountEntity>>> call(NoParams params) {
    return repository.getAccounts();
  }
}
