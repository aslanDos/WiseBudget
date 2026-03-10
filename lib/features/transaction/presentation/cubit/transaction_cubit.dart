import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
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
  final AccountCubit _accountCubit;

  TransactionCubit({
    required GetTransactions getTransactions,
    required GetTransactionsByAccount getTransactionsByAccount,
    required GetTransactionsByCategory getTransactionsByCategory,
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
    required AccountCubit accountCubit,
  })  : _getTransactions = getTransactions,
        _getTransactionsByAccount = getTransactionsByAccount,
        _getTransactionsByCategory = getTransactionsByCategory,
        _createTransaction = createTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _accountCubit = accountCubit,
        super(const TransactionState());

  Future<void> loadTransactions({bool recalculateBalances = true}) async {
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
      (transactions) {
        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: transactions,
        ));
        // Recalculate account balances to sync with existing transactions
        if (recalculateBalances) {
          _accountCubit.recalculateBalances(transactions);
        }
      },
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
      (created) {
        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: [created, ...state.transactions],
        ));
        // Update account balance
        _adjustAccountBalance(created.accountUuid, created.amount, created.type);
      },
    );
  }

  Future<void> editTransaction(TransactionEntity transaction) async {
    // Find the old transaction to reverse its effect
    final oldTransaction = state.transactions
        .where((t) => t.uuid == transaction.uuid)
        .firstOrNull;

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
        // Reverse old transaction effect and apply new one
        if (oldTransaction != null) {
          _reverseAccountBalance(
            oldTransaction.accountUuid,
            oldTransaction.amount,
            oldTransaction.type,
          );
        }
        _adjustAccountBalance(updated.accountUuid, updated.amount, updated.type);
      },
    );
  }

  Future<void> removeTransaction(String uuid) async {
    // Find the transaction to reverse its effect
    final transaction = state.transactions.where((t) => t.uuid == uuid).firstOrNull;

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
        // Reverse the transaction's effect on account balance
        if (transaction != null) {
          _reverseAccountBalance(
            transaction.accountUuid,
            transaction.amount,
            transaction.type,
          );
        }
      },
    );
  }

  /// Adjusts account balance based on transaction type.
  /// Expense: decreases balance, Income: increases balance
  void _adjustAccountBalance(
    String accountUuid,
    double amount,
    TransactionType type,
  ) {
    final delta = switch (type) {
      TransactionType.expense => -amount,
      TransactionType.income => amount,
      TransactionType.transfer => 0.0, // Transfer handled separately
    };
    if (delta != 0) {
      _accountCubit.adjustBalance(accountUuid, delta);
    }
  }

  /// Reverses a transaction's effect on account balance.
  void _reverseAccountBalance(
    String accountUuid,
    double amount,
    TransactionType type,
  ) {
    final delta = switch (type) {
      TransactionType.expense => amount, // Reverse: add back
      TransactionType.income => -amount, // Reverse: subtract
      TransactionType.transfer => 0.0,
    };
    if (delta != 0) {
      _accountCubit.adjustBalance(accountUuid, delta);
    }
  }
}
