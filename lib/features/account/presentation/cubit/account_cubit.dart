import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wisebuget/core/usecases/usecase.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/domain/usecases/account_usecases.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';

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
  }) : _getAccounts = getAccounts,
       _createAccount = createAccount,
       _updateAccount = updateAccount,
       _deleteAccount = deleteAccount,
       _seedDefaultAccount = seedDefaultAccount,
       super(const AccountState());

  // ─────────────────────────────────────────────────────────────────────────
  // CRUD Operations
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadAccounts() async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _getAccounts(const NoParams());

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (accounts) =>
          emit(state.copyWith(status: CubitStatus.success, accounts: accounts)),
    );
  }

  Future<void> addAccount(AccountEntity account) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _createAccount(CreateAccountParams(account: account));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (created) => emit(
        state.copyWith(
          status: CubitStatus.success,
          accounts: [...state.accounts, created],
        ),
      ),
    );
  }

  Future<void> editAccount(AccountEntity account) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _updateAccount(UpdateAccountParams(account: account));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (updated) {
        final updatedList = state.accounts.map((a) {
          return a.uuid == updated.uuid ? updated : a;
        }).toList();
        emit(
          state.copyWith(status: CubitStatus.success, accounts: updatedList),
        );
      },
    );
  }

  Future<void> removeAccount(String uuid) async {
    emit(state.copyWith(status: CubitStatus.loading));

    final result = await _deleteAccount(DeleteAccountParams(uuid: uuid));

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CubitStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) {
        final updatedList = state.accounts
            .where((a) => a.uuid != uuid)
            .toList();
        emit(
          state.copyWith(status: CubitStatus.success, accounts: updatedList),
        );
      },
    );
  }

  Future<void> seedDefaultAccount() async {
    _log.fine('Requesting default account seed');
    final result = await _seedDefaultAccount(const NoParams());
    result.fold(
      (failure) =>
          _log.warning('Seed default account failed: ${failure.message}'),
      (_) => _log.fine('Seed default account completed'),
    );
  }
}
