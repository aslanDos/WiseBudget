import 'package:equatable/equatable.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';

class RecurringTransactionOccurrence extends Equatable {
  final RecurringTransactionEntity template;
  final DateTime date;

  const RecurringTransactionOccurrence({
    required this.template,
    required this.date,
  });

  @override
  List<Object?> get props => [template, date];
}
