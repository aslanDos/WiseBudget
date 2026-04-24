import 'package:dartz/dartz.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

abstract class TransactionEffectsGateway {
  Future<Either<Failure, TransactionEntity>> createTransactionWithEffects(
    TransactionEntity transaction,
  );

  Future<Either<Failure, TransactionEntity>> updateTransactionWithEffects(
    TransactionEntity transaction,
  );

  Future<Either<Failure, void>> deleteTransactionWithEffects(String uuid);

  Future<Either<Failure, List<AccountEntity>>> recalculateAccountBalances(
    List<TransactionEntity> transactions,
  );
}
