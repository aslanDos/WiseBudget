import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';

class SeedDefaultAccount extends UseCase<void, NoParams> {
  final AccountRepository repository;

  SeedDefaultAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.seedDefaultAccount();
  }
}
