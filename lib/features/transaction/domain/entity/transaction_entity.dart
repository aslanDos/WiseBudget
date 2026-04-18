import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';

class TransactionEntity extends Equatable {
  final String uuid;
  final double amount;
  final String currency;
  final TransactionType type;
  final String categoryUuid;
  final String accountUuid;
  final String? toAccountUuid; // For transfers: destination account
  final String? note;
  final DateTime date;
  final DateTime createdDate;

  /// Validation constants
  static const int maxNoteLength = 256;

  const TransactionEntity({
    required this.uuid,
    required this.amount,
    required this.currency,
    required this.type,
    required this.categoryUuid,
    required this.accountUuid,
    this.toAccountUuid,
    this.note,
    required this.date,
    required this.createdDate,
  });

  /// Computed property - returns amount as Money value object
  Money get money => Money(amount, currency);

  /// Convenience getters
  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;
  bool get isTransfer => type == TransactionType.transfer;
  bool get isAdjustment => type == TransactionType.adjustment;
  bool get hasNote => note != null && note!.isNotEmpty;

  /// Validation
  bool get isValid {
    if (isAdjustment ? amount == 0 : amount <= 0) return false;
    if (currency.isEmpty) return false;
    if (accountUuid.isEmpty) return false;
    if (note != null && note!.length > maxNoteLength) return false;

    if (isTransfer) {
      return toAccountUuid != null && toAccountUuid!.isNotEmpty;
    }

    if (isAdjustment) return true;

    return categoryUuid.isNotEmpty;
  }

  TransactionEntity copyWith({
    String? uuid,
    double? amount,
    String? currency,
    TransactionType? type,
    String? categoryUuid,
    String? accountUuid,
    String? toAccountUuid,
    String? note,
    DateTime? date,
    DateTime? createdDate,
  }) {
    return TransactionEntity(
      uuid: uuid ?? this.uuid,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      type: type ?? this.type,
      categoryUuid: categoryUuid ?? this.categoryUuid,
      accountUuid: accountUuid ?? this.accountUuid,
      toAccountUuid: toAccountUuid ?? this.toAccountUuid,
      note: note ?? this.note,
      date: date ?? this.date,
      createdDate: createdDate ?? this.createdDate,
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
    date,
    createdDate,
  ];
}
