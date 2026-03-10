import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/usecases/account_usecases.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

final _log = Logger('AccountCubit');

class AccountCubit extends Cubit<AccountState> {
  final GetAccounts _getAccounts;
  final CreateAccount _createAccount;
  final UpdateAccount _updateAccount;
  final DeleteAccount _deleteAccount;
  final SeedDefaultAccount _seedDefaultAccount;

  AccountCubit({
    required GetAccounts getAccounts,
    required CreateAccount createAccount,
    required UpdateAccount updateAccount,
    required DeleteAccount deleteAccount,
    required SeedDefaultAccount seedDefaultAccount,
  })  : _getAccounts = getAccounts,
        _createAccount = createAccount,
        _updateAccount = updateAccount,
        _deleteAccount = deleteAccount,
        _seedDefaultAccount = seedDefaultAccount,
        super(const AccountState());

  Future<void> loadAccounts() async {
    emit(state.copyWith(status: AccountStatus.loading));

    final result = await _getAccounts(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountStatus.failure,
        errorMessage: failure.message,
      )),
      (accounts) => emit(state.copyWith(
        status: AccountStatus.success,
        accounts: accounts,
      )),
    );
  }

  Future<void> addAccount(AccountEntity account) async {
    final result = await _createAccount(CreateAccountParams(account: account));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountStatus.failure,
        errorMessage: failure.message,
      )),
      (created) => emit(state.copyWith(
        status: AccountStatus.success,
        accounts: [...state.accounts, created],
      )),
    );
  }

  Future<void> editAccount(AccountEntity account) async {
    final result = await _updateAccount(UpdateAccountParams(account: account));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountStatus.failure,
        errorMessage: failure.message,
      )),
      (updated) {
        final updatedList = state.accounts.map((a) {
          return a.uuid == updated.uuid ? updated : a;
        }).toList();
        emit(state.copyWith(
          status: AccountStatus.success,
          accounts: updatedList,
        ));
      },
    );
  }

  Future<void> removeAccount(String uuid) async {
    final result = await _deleteAccount(DeleteAccountParams(uuid: uuid));

    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountStatus.failure,
        errorMessage: failure.message,
      )),
      (_) {
        final updatedList = state.accounts.where((a) => a.uuid != uuid).toList();
        emit(state.copyWith(
          status: AccountStatus.success,
          accounts: updatedList,
        ));
      },
    );
  }

  Future<void> seedDefaultAccount() async {
    _log.fine('Requesting default account seed');
    final result = await _seedDefaultAccount(const NoParams());
    result.fold(
      (failure) => _log.warning('Seed default account failed: ${failure.message}'),
      (_) => _log.fine('Seed default account completed'),
    );
  }

  /// Adjusts the balance of an account by the given delta amount.
  /// Positive delta increases balance, negative delta decreases it.
  Future<void> adjustBalance(String accountUuid, double delta) async {
    final account = state.accounts.where((a) => a.uuid == accountUuid).firstOrNull;
    if (account == null) {
      _log.warning('Cannot adjust balance: account $accountUuid not found');
      return;
    }

    final updated = account.copyWith(balance: account.balance + delta);
    await editAccount(updated);
  }

  /// Recalculates all account balances based on the provided transactions.
  /// This ensures balances are in sync with actual transaction history.
  Future<void> recalculateBalances(List<TransactionEntity> transactions) async {
    // Ensure accounts are loaded first
    if (state.accounts.isEmpty && state.status != AccountStatus.loading) {
      await loadAccounts();
    }

    if (state.accounts.isEmpty) {
      _log.fine('No accounts to recalculate balances for');
      return;
    }

    _log.fine('Recalculating balances for ${state.accounts.length} accounts');

    // Calculate balance for each account from transactions
    final balanceMap = <String, double>{};

    for (final transaction in transactions) {
      final currentBalance = balanceMap[transaction.accountUuid] ?? 0.0;
      final delta = switch (transaction.type) {
        TransactionType.expense => -transaction.amount,
        TransactionType.income => transaction.amount,
        TransactionType.transfer => 0.0,
      };
      balanceMap[transaction.accountUuid] = currentBalance + delta;
    }

    // Update accounts with calculated balances
    final updatedAccounts = state.accounts.map((account) {
      final calculatedBalance = balanceMap[account.uuid] ?? 0.0;
      if (account.balance != calculatedBalance) {
        _log.fine(
          'Account ${account.name}: ${account.balance} -> $calculatedBalance',
        );
        return account.copyWith(balance: calculatedBalance);
      }
      return account;
    }).toList();

    // Persist updated accounts
    for (final account in updatedAccounts) {
      final original = state.accounts.firstWhere((a) => a.uuid == account.uuid);
      if (original.balance != account.balance) {
        await _updateAccount(UpdateAccountParams(account: account));
      }
    }

    emit(state.copyWith(
      status: AccountStatus.success,
      accounts: updatedAccounts,
    ));
  }
}
