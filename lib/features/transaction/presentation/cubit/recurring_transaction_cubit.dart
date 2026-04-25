import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/usecases/recurring_transaction_usecases.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_state.dart';

final _log = Logger('RecurringTransactionCubit');

class RecurringTransactionCubit extends Cubit<RecurringTransactionState> {
  final GetRecurringTransactions _getRecurringTransactions;
  final CreateRecurringTransaction _createRecurringTransaction;
  final UpdateRecurringTransaction _updateRecurringTransaction;
  final DeleteRecurringTransaction _deleteRecurringTransaction;

  RecurringTransactionCubit({
    required GetRecurringTransactions getRecurringTransactions,
    required CreateRecurringTransaction createRecurringTransaction,
    required UpdateRecurringTransaction updateRecurringTransaction,
    required DeleteRecurringTransaction deleteRecurringTransaction,
  }) : _getRecurringTransactions = getRecurringTransactions,
       _createRecurringTransaction = createRecurringTransaction,
       _updateRecurringTransaction = updateRecurringTransaction,
       _deleteRecurringTransaction = deleteRecurringTransaction,
       super(const RecurringTransactionState());

  Future<void> loadRecurringTransactions() async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _getRecurringTransactions(const NoParams());
    result.fold(
      (failure) => _emitFailure(
        'Failed to load recurring transactions',
        failure.message,
      ),
      (transactions) => emit(
        state.copyWith(status: CubitStatus.success, transactions: transactions),
      ),
    );
  }

  Future<void> addRecurringTransaction(
    RecurringTransactionEntity transaction,
  ) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _createRecurringTransaction(
      CreateRecurringTransactionParams(transaction: transaction),
    );
    result.fold(
      (failure) => _emitFailure(
        'Failed to create recurring transaction',
        failure.message,
      ),
      (created) => emit(
        state.copyWith(
          status: CubitStatus.success,
          transactions: [...state.transactions, created],
        ),
      ),
    );
  }

  Future<void> updateRecurringTransaction(
    RecurringTransactionEntity transaction,
  ) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _updateRecurringTransaction(
      UpdateRecurringTransactionParams(transaction: transaction),
    );
    result.fold(
      (failure) => _emitFailure(
        'Failed to update recurring transaction',
        failure.message,
      ),
      (updated) => emit(
        state.copyWith(
          status: CubitStatus.success,
          transactions: state.transactions
              .map((item) => item.uuid == updated.uuid ? updated : item)
              .toList(),
        ),
      ),
    );
  }

  Future<void> removeRecurringTransaction(String uuid) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _deleteRecurringTransaction(
      DeleteRecurringTransactionParams(uuid: uuid),
    );
    result.fold(
      (failure) => _emitFailure(
        'Failed to delete recurring transaction',
        failure.message,
      ),
      (_) => emit(
        state.copyWith(
          status: CubitStatus.success,
          transactions: state.transactions
              .where((item) => item.uuid != uuid)
              .toList(),
        ),
      ),
    );
  }

  void _emitFailure(String context, String message) {
    _log.warning('$context: $message');
    emit(state.copyWith(status: CubitStatus.failure, errorMessage: message));
  }
}
