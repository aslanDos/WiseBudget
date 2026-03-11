import 'package:objectbox/objectbox.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

@Entity()
class AccountModel {
  @Id()
  int id = 0;

  @Unique()
  String uuid;

  String name;
  String currency;
  double balance;

  @Index()
  int sortOrder;

  String iconCode;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  int? colorValue;

  AccountModel({
    this.id = 0,
    required this.uuid,
    required this.name,
    required this.currency,
    this.balance = 0.0,
    this.sortOrder = -1,
    required this.iconCode,
    DateTime? createdDate,
    this.colorValue,
  }) : createdDate = createdDate ?? DateTime.now();

  /// Convert to domain entity
  AccountEntity toEntity() {
    return AccountEntity(
      uuid: uuid,
      name: name,
      currency: currency,
      balance: balance,
      sortOrder: sortOrder,
      iconCode: iconCode,
      createdDate: createdDate,
      colorValue: colorValue,
    );
  }

  /// Create from domain entity
  factory AccountModel.fromEntity(AccountEntity entity, {int id = 0}) {
    return AccountModel(
      id: id,
      uuid: entity.uuid,
      name: entity.name,
      currency: entity.currency,
      balance: entity.balance,
      sortOrder: entity.sortOrder,
      iconCode: entity.iconCode,
      createdDate: entity.createdDate,
      colorValue: entity.colorValue,
    );
  }
}
