import 'package:objectbox/objectbox.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';

@Entity()
class CategoryModel {
  @Id()
  int id = 0;

  @Unique()
  String uuid;

  String name;

  @Index()
  int sortOrder;

  String iconCode;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  String type;

  CategoryModel({
    this.id = 0,
    required this.uuid,
    required this.name,
    this.sortOrder = -1,
    required this.iconCode,
    required this.type,
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
  CategoryEntity toEntity() {
    return CategoryEntity(
      uuid: uuid,
      name: name,
      sortOrder: sortOrder,
      iconCode: iconCode,
      createdDate: createdDate,
      type: transactionType,
    );
  }

  /// Create from domain entity
  factory CategoryModel.fromEntity(CategoryEntity entity, {int id = 0}) {
    return CategoryModel(
      id: id,
      uuid: entity.uuid,
      name: entity.name,
      sortOrder: entity.sortOrder,
      iconCode: entity.iconCode,
      createdDate: entity.createdDate,
      type: entity.type.value,
    );
  }
}
