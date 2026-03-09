import 'package:equatable/equatable.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

enum TransactionStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionEntity> transactions;
  final String? errorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.errorMessage,
  });

  TransactionState copyWith({
    TransactionStatus? status,
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
