import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
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

  // ─────────────────────────────────────────────────────────────────────────
  // Load Operations
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadTransactions({bool recalculateBalances = false}) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final result = await _getTransactions(const NoParams());

    result.fold(
      (failure) => _emitFailure('Failed to load transactions', failure.message),
      (transactions) {
        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: transactions,
        ));
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
      (failure) => _emitFailure('Failed to load by account', failure.message),
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
      (failure) => _emitFailure('Failed to load by category', failure.message),
      (transactions) => emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: transactions,
      )),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> addTransaction(TransactionEntity transaction) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final result = await _createTransaction(
      CreateTransactionParams(transaction: transaction),
    );

    result.fold(
      (failure) => _emitFailure('Failed to create transaction', failure.message),
      (created) {
        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: [created, ...state.transactions],
        ));
        _accountCubit.applyTransactionEffect(created);
      },
    );
  }

  Future<void> editTransaction(TransactionEntity transaction) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final oldTransaction = _findTransaction(transaction.uuid);

    final result = await _updateTransaction(
      UpdateTransactionParams(transaction: transaction),
    );

    result.fold(
      (failure) => _emitFailure('Failed to update transaction', failure.message),
      (updated) {
        final updatedList = state.transactions
            .map((t) => t.uuid == updated.uuid ? updated : t)
            .toList();

        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: updatedList,
        ));

        // Reverse old effect, apply new effect
        if (oldTransaction != null) {
          _accountCubit.reverseTransactionEffect(oldTransaction);
        }
        _accountCubit.applyTransactionEffect(updated);
      },
    );
  }

  Future<void> removeTransaction(String uuid) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final transaction = _findTransaction(uuid);

    final result = await _deleteTransaction(DeleteTransactionParams(uuid: uuid));

    result.fold(
      (failure) => _emitFailure('Failed to delete transaction', failure.message),
      (_) {
        final updatedList = state.transactions
            .where((t) => t.uuid != uuid)
            .toList();

        emit(state.copyWith(
          status: TransactionStatus.success,
          transactions: updatedList,
        ));

        if (transaction != null) {
          _accountCubit.reverseTransactionEffect(transaction);
        }
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Private Helpers
  // ─────────────────────────────────────────────────────────────────────────

  TransactionEntity? _findTransaction(String uuid) {
    return state.transactions.where((t) => t.uuid == uuid).firstOrNull;
  }

  void _emitFailure(String context, String message) {
    _log.warning('$context: $message');
    emit(state.copyWith(
      status: TransactionStatus.failure,
      errorMessage: message,
    ));
  }
}
