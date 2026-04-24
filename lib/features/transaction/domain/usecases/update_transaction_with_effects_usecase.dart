import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_effects_gateway.dart';

class UpdateTransactionWithEffects
    extends UseCase<TransactionEntity, UpdateTransactionWithEffectsParams> {
  final TransactionEffectsGateway _gateway;

  UpdateTransactionWithEffects(this._gateway);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    UpdateTransactionWithEffectsParams params,
  ) async {
    return _gateway.updateTransactionWithEffects(params.transaction);
  }
}

class UpdateTransactionWithEffectsParams extends Equatable {
  final TransactionEntity transaction;

  const UpdateTransactionWithEffectsParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
