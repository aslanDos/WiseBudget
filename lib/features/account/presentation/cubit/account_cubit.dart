import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/usecases/account_usecases.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final GetAccounts _getAccounts;
  final CreateAccount _createAccount;
  final UpdateAccount _updateAccount;
  final DeleteAccount _deleteAccount;

  AccountCubit({
    required GetAccounts getAccounts,
    required CreateAccount createAccount,
    required UpdateAccount updateAccount,
    required DeleteAccount deleteAccount,
  })  : _getAccounts = getAccounts,
        _createAccount = createAccount,
        _updateAccount = updateAccount,
        _deleteAccount = deleteAccount,
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
}
