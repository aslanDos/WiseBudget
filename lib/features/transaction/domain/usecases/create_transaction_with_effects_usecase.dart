import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_effects_gateway.dart';

class CreateTransactionWithEffects
    extends UseCase<TransactionEntity, CreateTransactionWithEffectsParams> {
  final TransactionEffectsGateway _gateway;

  CreateTransactionWithEffects(this._gateway);

  @override
  Future<Either<Failure, TransactionEntity>> call(
    CreateTransactionWithEffectsParams params,
  ) async {
    return _gateway.createTransactionWithEffects(params.transaction);
  }
}

class CreateTransactionWithEffectsParams extends Equatable {
  final TransactionEntity transaction;

  const CreateTransactionWithEffectsParams({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}
