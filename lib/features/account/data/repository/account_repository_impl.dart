import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/account/data/datasource/account_local_datasource.dart';
import 'package:wisebuget/features/account/data/model/account_model.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/repository/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountLocalDataSource localDataSource;

  AccountRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<AccountEntity>>> getAccounts() async {
    try {
      final models = await localDataSource.getAccounts();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get accounts: $e'));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> getAccountById(String uuid) async {
    try {
      final model = await localDataSource.getAccountByUuid(uuid);
      if (model == null) {
        return Left(NotFoundFailure('Account not found: $uuid'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get account: $e'));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> createAccount(AccountEntity account) async {
    try {
      final model = AccountModel.fromEntity(account);
      final created = await localDataSource.createAccount(model);
      return Right(created.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to create account: $e'));
    }
  }

  @override
  Future<Either<Failure, AccountEntity>> updateAccount(AccountEntity account) async {
    try {
      final model = AccountModel.fromEntity(account);
      final updated = await localDataSource.updateAccount(model);
      return Right(updated.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to update account: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(String uuid) async {
    try {
      await localDataSource.deleteAccount(uuid);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete account: $e'));
    }
  }
}
