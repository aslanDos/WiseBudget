import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';

class RecurringTransactionState extends Equatable {
  final CubitStatus status;
  final List<RecurringTransactionEntity> transactions;
  final String? errorMessage;

  const RecurringTransactionState({
    this.status = CubitStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  RecurringTransactionState copyWith({
    CubitStatus? status,
    List<RecurringTransactionEntity>? transactions,
    String? errorMessage,
  }) {
    return RecurringTransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
