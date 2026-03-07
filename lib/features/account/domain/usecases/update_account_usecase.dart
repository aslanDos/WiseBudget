import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';

class UpdateAccount extends UseCase<AccountEntity, UpdateAccountParams> {
  final AccountRepository repository;

  UpdateAccount(this.repository);

  @override
  Future<Either<Failure, AccountEntity>> call(UpdateAccountParams params) {
    return repository.updateAccount(params.account);
  }
}

class UpdateAccountParams extends Equatable {
  final AccountEntity account;

  const UpdateAccountParams({required this.account});

  @override
  List<Object> get props => [account];
}
