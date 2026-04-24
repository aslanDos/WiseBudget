import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/errors/failures.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/repository/transaction_effects_gateway.dart';

class DeleteTransactionWithEffects
    extends UseCase<void, DeleteTransactionWithEffectsParams> {
  final TransactionEffectsGateway _gateway;

  DeleteTransactionWithEffects(this._gateway);

  @override
  Future<Either<Failure, void>> call(
    DeleteTransactionWithEffectsParams params,
  ) async {
    return _gateway.deleteTransactionWithEffects(params.uuid);
  }
}

class DeleteTransactionWithEffectsParams extends Equatable {
  final String uuid;

  const DeleteTransactionWithEffectsParams({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}
