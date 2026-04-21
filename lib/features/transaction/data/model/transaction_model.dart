import 'package:objectbox/objectbox.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

@Entity()
class TransactionModel {
  @Id()
  int id = 0;

  @Unique()
  String uuid;

  double amount;
  String currency;
  String type;

  @Index()
  String categoryUuid;

  @Index()
  String accountUuid;

  /// For transfers: destination account UUID
  String? toAccountUuid;

  String? note;

  @Property(type: PropertyType.date)
  @Index()
  DateTime date;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  double? exchangeRate;
  double? convertedAmount;
  String? baseCurrency;

  TransactionModel({
    this.id = 0,
    required this.uuid,
    required this.amount,
    required this.currency,
    required this.type,
    required this.categoryUuid,
    required this.accountUuid,
    this.toAccountUuid,
    this.note,
    required this.date,
    DateTime? createdDate,
    this.exchangeRate,
    this.convertedAmount,
    this.baseCurrency,
  }) : createdDate = createdDate ?? DateTime.now();

  @Transient()
  TransactionType get transactionType {
    try {
      return TransactionType.values.firstWhere(
        (element) => element.label == type,
      );
    } catch (e) {
      return TransactionType.expense;
    }
  }

  set transactionType(TransactionType value) {
    type = value.label;
  }

  /// Convert to domain entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      uuid: uuid,
      amount: amount,
      currency: currency,
      type: transactionType,
      categoryUuid: categoryUuid,
      accountUuid: accountUuid,
      toAccountUuid: toAccountUuid,
      note: note,
      date: date,
      createdDate: createdDate,
      exchangeRate: exchangeRate,
      convertedAmount: convertedAmount,
      baseCurrency: baseCurrency,
    );
  }

  /// Create from domain entity
  factory TransactionModel.fromEntity(TransactionEntity entity, {int id = 0}) {
    return TransactionModel(
      id: id,
      uuid: entity.uuid,
      amount: entity.amount,
      currency: entity.currency,
      type: entity.type.label,
      categoryUuid: entity.categoryUuid,
      accountUuid: entity.accountUuid,
      toAccountUuid: entity.toAccountUuid,
      note: entity.note,
      date: entity.date,
      createdDate: entity.createdDate,
      exchangeRate: entity.exchangeRate,
      convertedAmount: entity.convertedAmount,
      baseCurrency: entity.baseCurrency,
    );
  }
}
