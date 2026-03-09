import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/usecases/transaction_usecases.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';

final _log = Logger('TransactionCubit');

class TransactionCubit extends Cubit<TransactionState> {
  final GetTransactions _getTransactions;
  final GetTransactionsByAccount _getTransactionsByAccount;
  final GetTransactionsByCategory _getTransactionsByCategory;
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  TransactionCubit({
    required GetTransactions getTransactions,
    required GetTransactionsByAccount getTransactionsByAccount,
    required GetTransactionsByCategory getTransactionsByCategory,
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
  })  : _getTransactions = getTransactions,
        _getTransactionsByAccount = getTransactionsByAccount,
        _getTransactionsByCategory = getTransactionsByCategory,
        _createTransaction = createTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        super(const TransactionState());

  Future<void> loadTransactions() async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final result = await _getTransactions(const NoParams());

    result.fold(
      (failure) {
        _log.warning('Failed to load transactions: ${failure.message}');
        emit(state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (transactions) => emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: transactions,
      )),
    );
  }

  Future<void> loadTransactionsByAccount(String accountUuid) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final result = await _getTransactionsByAccount(
      GetTransactionsByAccountParams(accountUuid: accountUuid),
    );

    result.fold(
      (failure) {
        _log.warning('Failed to load transactions by account: ${failure.message}');
        emit(state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (transactions) => emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: transactions,
      )),
    );
  }

  Future<void> loadTransactionsByCategory(String categoryUuid) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final result = await _getTransactionsByCategory(
      GetTransactionsByCategoryParams(categoryUuid: categoryUuid),
    );

    result.fold(
      (failure) {
        _log.warning('Failed to load transactions by category: ${failure.message}');
        emit(state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (transactions) => emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: transactions,
      )),
    );
  }

  Future<void> addTransaction(TransactionEntity transaction) async {
    final result = await _createTransaction(
      CreateTransactionParams(transaction: transaction),
    );

    result.fold(
      (failure) {
        _log.warning('Failed to create transaction: ${failure.message}');
        emit(state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (created) => emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: [created, ...state.transactions],
      )),
    );
  }

  Future<void> editTransaction(TransactionEntity transaction) async {
    final result = await _updateTransaction(
      UpdateTransactionParams(transaction: transaction),
    );

    result.fold(
      (failure) {
        _log.warning('Failed to update transaction: ${failure.message}');
        emit(state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (updated) {
        final updatedList = state.transactions.map((t) {
          return t.uuid == updated.uuid ? updated : t;
        }).toList();
        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: updatedList,
        ));
      },
    );
  }

  Future<void> removeTransaction(String uuid) async {
    final result = await _deleteTransaction(DeleteTransactionParams(uuid: uuid));

    result.fold(
      (failure) {
        _log.warning('Failed to delete transaction: ${failure.message}');
        emit(state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (_) {
        final updatedList =
            state.transactions.where((t) => t.uuid != uuid).toList();
        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: updatedList,
        ));
      },
    );
  }
}
