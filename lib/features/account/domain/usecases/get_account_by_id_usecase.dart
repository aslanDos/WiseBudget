import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';

class GetAccountById extends UseCase<AccountEntity, GetAccountByIdParams> {
  final AccountRepository repository;

  GetAccountById(this.repository);

  @override
  Future<Either<Failure, AccountEntity>> call(GetAccountByIdParams params) {
    return repository.getAccountById(params.uuid);
  }
}

class GetAccountByIdParams extends Equatable {
  final String uuid;

  const GetAccountByIdParams({required this.uuid});

  @override
  List<Object> get props => [uuid];
}
