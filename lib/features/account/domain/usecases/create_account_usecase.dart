import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';

class CreateAccount extends UseCase<AccountEntity, CreateAccountParams> {
  final AccountRepository repository;

  CreateAccount(this.repository);

  @override
  Future<Either<Failure, AccountEntity>> call(CreateAccountParams params) {
    return repository.createAccount(params.account);
  }
}

class CreateAccountParams extends Equatable {
  final AccountEntity account;

  const CreateAccountParams({required this.account});

  @override
  List<Object> get props => [account];
}
