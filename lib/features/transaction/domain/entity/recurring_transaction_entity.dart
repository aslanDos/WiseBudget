import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';

class RecurringTransactionEntity extends Equatable {
  final String uuid;
  final double amount;
  final String currency;
  final TransactionType type;
  final String categoryUuid;
  final String accountUuid;
  final String? toAccountUuid;
  final String? note;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdDate;
  final RecurrenceFrequency frequency;
  final bool isActive;

  const RecurringTransactionEntity({
    required this.uuid,
    required this.amount,
    required this.currency,
    required this.type,
    required this.categoryUuid,
    required this.accountUuid,
    this.toAccountUuid,
    this.note,
    required this.startDate,
    this.endDate,
    required this.createdDate,
    required this.frequency,
    this.isActive = true,
  });

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;

  bool get isValid {
    if (amount <= 0) return false;
    if (currency.isEmpty || accountUuid.isEmpty) return false;
    if (type == TransactionType.adjustment) return false;
    if (isTransfer) {
      return toAccountUuid != null &&
          toAccountUuid!.isNotEmpty &&
          toAccountUuid != accountUuid;
    }
    return categoryUuid.isNotEmpty;
  }

  RecurringTransactionEntity copyWith({
    String? uuid,
    double? amount,
    String? currency,
    TransactionType? type,
    String? categoryUuid,
    String? accountUuid,
    String? toAccountUuid,
    String? note,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdDate,
    RecurrenceFrequency? frequency,
    bool? isActive,
  }) {
    return RecurringTransactionEntity(
      uuid: uuid ?? this.uuid,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      accountUuid: accountUuid ?? this.accountUuid,
      toAccountUuid: toAccountUuid ?? this.toAccountUuid,
      note: note ?? this.note,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdDate: createdDate ?? this.createdDate,
      frequency: frequency ?? this.frequency,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    amount,
    currency,
    type,
    categoryUuid,
    accountUuid,
    toAccountUuid,
    note,
    startDate,
    endDate,
    createdDate,
    frequency,
    isActive,
  ];
}
