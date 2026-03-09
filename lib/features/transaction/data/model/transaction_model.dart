import 'package:objectbox/objectbox.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
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

  String? note;

  @Property(type: PropertyType.date)
  @Index()
  DateTime date;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  TransactionModel({
    this.id = 0,
    required this.uuid,
    required this.amount,
    required this.currency,
    required this.type,
    required this.categoryUuid,
    required this.accountUuid,
    this.note,
    required this.date,
    DateTime? createdDate,
  }) : createdDate = createdDate ?? DateTime.now();

  @Transient()
  TransactionType get transactionType {
    try {
      return TransactionType.values.firstWhere(
        (element) => element.value == type,
      );
    } catch (e) {
      return TransactionType.expense;
    }
  }

  set transactionType(TransactionType value) {
    type = value.value;
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
      note: note,
      date: date,
      createdDate: createdDate,
    );
  }

  /// Create from domain entity
  factory TransactionModel.fromEntity(TransactionEntity entity, {int id = 0}) {
    return TransactionModel(
      id: id,
      uuid: entity.uuid,
      amount: entity.amount,
      currency: entity.currency,
      type: entity.type.value,
      categoryUuid: entity.categoryUuid,
      accountUuid: entity.accountUuid,
      note: entity.note,
      date: entity.date,
      createdDate: entity.createdDate,
    );
  }
}
