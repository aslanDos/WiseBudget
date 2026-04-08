import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class TransactionState extends Equatable {
  final CubitStatus status;
  final List<TransactionEntity> transactions;
  final String? errorMessage;

  const TransactionState({
    this.status = CubitStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  TransactionState copyWith({
    CubitStatus? status,
    List<TransactionEntity>? transactions,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
