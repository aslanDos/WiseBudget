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

  @Index()
  int sortOrder;

  String iconCode;

  AccountModel({
    this.id = 0,
    required this.uuid,
    required this.name,
    required this.currency,
    this.sortOrder = -1,
    required this.iconCode,
  });

  /// Convert to domain entity
  AccountEntity toEntity() {
    return AccountEntity(
      uuid: uuid,
      name: name,
      currency: currency,
      sortOrder: sortOrder,
      iconCode: iconCode,
    );
  }

  /// Create from domain entity
  factory AccountModel.fromEntity(AccountEntity entity, {int id = 0}) {
    return AccountModel(
      id: id,
      uuid: entity.uuid,
      name: entity.name,
      currency: entity.currency,
      sortOrder: entity.sortOrder,
      iconCode: entity.iconCode,
    );
  }
}
