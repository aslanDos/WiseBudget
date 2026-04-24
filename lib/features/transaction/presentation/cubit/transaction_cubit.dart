import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/usecases/account_usecases.dart';
import 'package:wisebuget/features/exchange_rate/domain/usecases/get_or_fetch_exchange_rate.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/usecases/transaction_usecases.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';

final _log = Logger('TransactionCubit');

class TransactionCubit extends Cubit<TransactionState> {
  final GetTransactions _getTransactions;
  final GetTransactionsByAccount _getTransactionsByAccount;
  final GetTransactionsByCategory _getTransactionsByCategory;
  final CreateTransactionWithEffects _createTransactionWithEffects;
  final UpdateTransactionWithEffects _updateTransactionWithEffects;
  final DeleteTransactionWithEffects _deleteTransactionWithEffects;
  final GetOrFetchExchangeRate _getOrFetchExchangeRate;
  final RecalculateAccountBalances _recalculateAccountBalances;
  final LocalPreferences _prefs;

  TransactionCubit({
    required GetTransactions getTransactions,
    required GetTransactionsByAccount getTransactionsByAccount,
    required GetTransactionsByCategory getTransactionsByCategory,
    required CreateTransactionWithEffects createTransactionWithEffects,
    required UpdateTransactionWithEffects updateTransactionWithEffects,
    required DeleteTransactionWithEffects deleteTransactionWithEffects,
    required GetOrFetchExchangeRate getOrFetchExchangeRate,
    required RecalculateAccountBalances recalculateAccountBalances,
    required LocalPreferences prefs,
  }) : _getTransactions = getTransactions,
       _getTransactionsByAccount = getTransactionsByAccount,
       _getTransactionsByCategory = getTransactionsByCategory,
       _createTransactionWithEffects = createTransactionWithEffects,
       _updateTransactionWithEffects = updateTransactionWithEffects,
       _getOrFetchExchangeRate = getOrFetchExchangeRate,
       _deleteTransactionWithEffects = deleteTransactionWithEffects,
       _recalculateAccountBalances = recalculateAccountBalances,
       _prefs = prefs,
       super(const TransactionState());

  // ─────────────────────────────────────────────────────────────────────────
  // Load Operations
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadTransactions({bool recalculateBalances = false}) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _getTransactions(const NoParams());

    result.fold(
      (failure) => _emitFailure('Failed to load transactions', failure.message),
      (transactions) {
        emit(
          state.copyWith(
            status: CubitStatus.success,
            transactions: transactions,
          ),
        );
        if (recalculateBalances) {
          _recalculateAccountBalances(
            RecalculateAccountBalancesParams(transactions: transactions),
          );
        }
      },
    );
  }

  Future<void> loadTransactionsByAccount(String accountUuid) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _getTransactionsByAccount(
      GetTransactionsByAccountParams(accountUuid: accountUuid),
    );

    result.fold(
      (failure) => _emitFailure('Failed to load by account', failure.message),
      (transactions) => emit(
        state.copyWith(status: CubitStatus.success, transactions: transactions),
      ),
    );
  }

  Future<void> loadTransactionsByCategory(String categoryUuid) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _getTransactionsByCategory(
      GetTransactionsByCategoryParams(categoryUuid: categoryUuid),
    );

    result.fold(
      (failure) => _emitFailure('Failed to load by category', failure.message),
      (transactions) => emit(
        state.copyWith(status: CubitStatus.success, transactions: transactions),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> addTransaction(TransactionEntity transaction) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _createTransactionWithEffects(
      CreateTransactionWithEffectsParams(
        transaction: await _attachExchangeRate(transaction),
      ),
    );

    result.fold(
      (failure) =>
          _emitFailure('Failed to create transaction', failure.message),
      (created) {
        emit(
          state.copyWith(
            status: CubitStatus.success,
            transactions: [created, ...state.transactions],
          ),
        );
      },
    );
  }

  Future<TransactionEntity> _attachExchangeRate(TransactionEntity tx) async {
    final baseCurrency = _prefs.currency;
    if (tx.currency == baseCurrency) {
      return tx.copyWith(
        exchangeRate: 1.0,
        convertedAmount: tx.amount,
        baseCurrency: baseCurrency,
      );
    }
    final result = await _getOrFetchExchangeRate(
      GetOrFetchRateParams(from: tx.currency, to: baseCurrency, date: tx.date),
    );
    return result.fold(
      (failure) {
        _log.warning('Could not resolve exchange rate: ${failure.message}');
        return tx.copyWith(baseCurrency: baseCurrency);
      },
      (rateEntity) {
        if (rateEntity == null) return tx.copyWith(baseCurrency: baseCurrency);
        return tx.copyWith(
          exchangeRate: rateEntity.rate,
          convertedAmount: tx.amount * rateEntity.rate,
          baseCurrency: baseCurrency,
        );
      },
    );
  }

  Future<void> editTransaction(TransactionEntity transaction) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _updateTransactionWithEffects(
      UpdateTransactionWithEffectsParams(
        transaction: await _attachExchangeRate(transaction),
      ),
    );

    result.fold(
      (failure) =>
          _emitFailure('Failed to update transaction', failure.message),
      (updated) {
        final updatedList = state.transactions
            .map((t) => t.uuid == updated.uuid ? updated : t)
            .toList();

        emit(
          state.copyWith(
            status: CubitStatus.success,
            transactions: updatedList,
          ),
        );
      },
    );
  }

  Future<void> removeTransaction(String uuid) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _deleteTransactionWithEffects(
      DeleteTransactionWithEffectsParams(uuid: uuid),
    );

    result.fold(
      (failure) =>
          _emitFailure('Failed to delete transaction', failure.message),
      (_) {
        final updatedList = state.transactions
            .where((t) => t.uuid != uuid)
            .toList();

        emit(
          state.copyWith(
            status: CubitStatus.success,
            transactions: updatedList,
          ),
        );
      },
    );
  }

  void _emitFailure(String context, String message) {
    _log.warning('$context: $message');
    emit(state.copyWith(status: CubitStatus.failure, errorMessage: message));
  }
}
