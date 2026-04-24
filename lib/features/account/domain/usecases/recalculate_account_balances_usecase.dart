import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_effects_gateway.dart';

class RecalculateAccountBalances
    extends UseCase<List<AccountEntity>, RecalculateAccountBalancesParams> {
  final TransactionEffectsGateway _gateway;

  RecalculateAccountBalances(this._gateway);

  @override
  Future<Either<Failure, List<AccountEntity>>> call(
    RecalculateAccountBalancesParams params,
  ) async {
    return _gateway.recalculateAccountBalances(params.transactions);
  }
}

class RecalculateAccountBalancesParams extends Equatable {
  final List<TransactionEntity> transactions;

  const RecalculateAccountBalancesParams({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}
