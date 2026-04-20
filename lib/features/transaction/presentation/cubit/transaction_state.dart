import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/cubit/list_cubit_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class TransactionState extends ListCubitState<TransactionEntity> {
  const TransactionState({
    super.status,
    List<TransactionEntity> transactions = const [],
    super.errorMessage,
  }) : super(items: transactions);

  List<TransactionEntity> get transactions => items;

  TransactionState copyWith({
    CubitStatus? status,
    List<TransactionEntity>? transactions,
    String? errorMessage,
  }) => TransactionState(
    status: status ?? this.status,
    transactions: transactions ?? items,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
