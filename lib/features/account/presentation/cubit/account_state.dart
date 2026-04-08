import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class AccountState extends Equatable {
  final CubitStatus status;
  final List<AccountEntity> accounts;
  final String? errorMessage;

  const AccountState({
    this.status = CubitStatus.initial,
    this.accounts = const [],
    this.errorMessage,
  });

  AccountState copyWith({
    CubitStatus? status,
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
