import 'package:equatable/equatable.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

enum AccountStatus { initial, loading, success, failure }

class AccountState extends Equatable {
  final AccountStatus status;
  final List<AccountEntity> accounts;
  final String? errorMessage;

  const AccountState({
    this.status = AccountStatus.initial,
    this.accounts = const [],
    this.errorMessage,
  });

  AccountState copyWith({
    AccountStatus? status,
    List<AccountEntity>? accounts,
    String? errorMessage,
  }) {
    return AccountState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, accounts, errorMessage];
}
