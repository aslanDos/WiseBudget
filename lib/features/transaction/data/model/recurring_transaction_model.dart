import 'package:objectbox/objectbox.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';

@Entity()
class RecurringTransactionModel {
  @Id()
  int id = 0;

  @Unique()
  String uuid;

  double amount;
  String currency;
  String type;
  String frequency;
  String categoryUuid;
  String accountUuid;
  String? toAccountUuid;
  String? note;

  @Property(type: PropertyType.date)
  DateTime startDate;

  @Property(type: PropertyType.date)
  DateTime? endDate;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  bool isActive;

  RecurringTransactionModel({
    this.id = 0,
    required this.uuid,
    required this.amount,
    required this.currency,
    required this.type,
    required this.frequency,
    required this.categoryUuid,
    required this.accountUuid,
    this.toAccountUuid,
    this.note,
    required this.startDate,
    this.endDate,
    DateTime? createdDate,
    this.isActive = true,
  }) : createdDate = createdDate ?? DateTime.now();

  TransactionType get transactionType => TransactionType.values.firstWhere(
    (value) => value.label == type,
    orElse: () => TransactionType.expense,
  );

  RecurrenceFrequency get recurrenceFrequency =>
      RecurrenceFrequency.values.firstWhere(
        (value) => value.label == frequency,
        orElse: () => RecurrenceFrequency.monthly,
      );

  RecurringTransactionEntity toEntity() {
    return RecurringTransactionEntity(
      uuid: uuid,
      amount: amount,
      currency: currency,
      type: transactionType,
      categoryUuid: categoryUuid,
      accountUuid: accountUuid,
      toAccountUuid: toAccountUuid,
      note: note,
      startDate: startDate,
      endDate: endDate,
      createdDate: createdDate,
      frequency: recurrenceFrequency,
      isActive: isActive,
    );
  }

  factory RecurringTransactionModel.fromEntity(
    RecurringTransactionEntity entity, {
    int id = 0,
  }) {
    return RecurringTransactionModel(
      id: id,
      uuid: entity.uuid,
      amount: entity.amount,
      currency: entity.currency,
      type: entity.type.label,
      frequency: entity.frequency.label,
      categoryUuid: entity.categoryUuid,
      accountUuid: entity.accountUuid,
      toAccountUuid: entity.toAccountUuid,
      note: entity.note,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdDate: entity.createdDate,
      isActive: entity.isActive,
    );
  }
}
