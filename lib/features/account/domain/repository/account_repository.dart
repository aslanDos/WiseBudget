import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

abstract class AccountRepository {
  /// Get all accounts sorted by sortOrder
  Future<Either<Failure, List<AccountEntity>>> getAccounts();

  /// Get account by uuid
  Future<Either<Failure, AccountEntity>> getAccountById(String uuid);

  /// Create a new account
  Future<Either<Failure, AccountEntity>> createAccount(AccountEntity account);

  /// Update an existing account
  Future<Either<Failure, AccountEntity>> updateAccount(AccountEntity account);

  /// Delete account by uuid
  Future<Either<Failure, void>> deleteAccount(String uuid);

  /// Seed default account if no accounts exist
  Future<Either<Failure, void>> seedDefaultAccount();
}
