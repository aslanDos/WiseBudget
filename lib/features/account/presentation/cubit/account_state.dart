import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/cubit/list_cubit_state.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class AccountState extends ListCubitState<AccountEntity> {
  const AccountState({
    super.status,
    List<AccountEntity> accounts = const [],
    super.errorMessage,
  }) : super(items: accounts);

  List<AccountEntity> get accounts => items;

  AccountState copyWith({
    CubitStatus? status,
    List<AccountEntity>? accounts,
    String? errorMessage,
  }) => AccountState(
    status: status ?? this.status,
    accounts: accounts ?? items,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
