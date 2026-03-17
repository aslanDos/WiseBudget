import 'dart:convert';

import 'package:objectbox/objectbox.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';

@Entity()
class BudgetModel {
  @Id()
  int id = 0;

  @Unique()
  String uuid;

  String name;
  double limit;
  String currency;

  /// Stored as string (weekly, monthly, custom)
  String period;

  @Property(type: PropertyType.date)
  DateTime startDate;

  @Property(type: PropertyType.date)
  DateTime? endDate;

  /// Stored as JSON string: ["uuid1", "uuid2"]
  String categoryUuidsJson;

  /// Stored as JSON string: ["uuid1", "uuid2"]
  String accountUuidsJson;

  String iconCode;
  int colorValue;

  @Property(type: PropertyType.date)
  DateTime createdDate;

  bool isArchived;

  BudgetModel({
    this.id = 0,
    required this.uuid,
    required this.name,
    required this.limit,
    required this.currency,
    required this.period,
    required this.startDate,
    this.endDate,
    required this.categoryUuidsJson,
    required this.accountUuidsJson,
    required this.iconCode,
    required this.colorValue,
    DateTime? createdDate,
    this.isArchived = false,
  }) : createdDate = createdDate ?? DateTime.now();

  /// Convert to domain entity
  BudgetEntity toEntity() {
    return BudgetEntity(
      uuid: uuid,
      name: name,
      limit: limit,
      currency: currency,
      period: BudgetPeriod.fromString(period),
      startDate: startDate,
      endDate: endDate,
      categoryUuids: _parseJsonList(categoryUuidsJson),
      accountUuids: _parseJsonList(accountUuidsJson),
      iconCode: iconCode,
      colorValue: colorValue,
      createdDate: createdDate,
      isArchived: isArchived,
    );
  }

  /// Create from domain entity
  factory BudgetModel.fromEntity(BudgetEntity entity, {int id = 0}) {
    return BudgetModel(
      id: id,
      uuid: entity.uuid,
      name: entity.name,
      limit: entity.limit,
      currency: entity.currency,
      period: entity.period.value,
      startDate: entity.startDate,
      endDate: entity.endDate,
      categoryUuidsJson: _toJsonList(entity.categoryUuids),
      accountUuidsJson: _toJsonList(entity.accountUuids),
      iconCode: entity.iconCode,
      colorValue: entity.colorValue,
      createdDate: entity.createdDate,
      isArchived: entity.isArchived,
    );
  }

  /// Parse JSON string to list
  static List<String> _parseJsonList(String jsonString) {
    if (jsonString.isEmpty || jsonString == '[]') return [];
    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<String>();
    } catch (_) {
      return [];
    }
  }

  /// Convert list to JSON string
  static String _toJsonList(List<String> list) {
    if (list.isEmpty) return '[]';
    return json.encode(list);
  }
}
