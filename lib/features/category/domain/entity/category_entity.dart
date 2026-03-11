import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';

class CategoryEntity extends Equatable {
  final String uuid;
  final String name;
  final int sortOrder;
  final String iconCode;
  final DateTime createdDate;
  final TransactionType type;
  final int? colorValue;
  final bool? _visible;

  /// Returns true if category is visible (null is treated as visible)
  bool get visible => _visible ?? true;

  /// Raw visibility value for persistence (null means visible by default)
  bool? get visibleRaw => _visible;

  const CategoryEntity({
    required this.uuid,
    required this.name,
    this.sortOrder = -1,
    required this.iconCode,
    required this.createdDate,
    required this.type,
    this.colorValue,
    bool? visible,
  }) : _visible = visible;

  CategoryEntity copyWith({
    String? uuid,
    String? name,
    int? sortOrder,
    String? iconCode,
    DateTime? createdDate,
    TransactionType? type,
    int? colorValue,
    bool? visible,
  }) {
    return CategoryEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      iconCode: iconCode ?? this.iconCode,
      createdDate: createdDate ?? this.createdDate,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
      visible: visible ?? _visible,
    );
  }

  /// Validation constants
  static const int maxNameLength = 48;

  /// Computed property - resolves icon from iconCode
  IconData get icon => AppIcons.fromCode(iconCode);

  /// Computed property - returns Color from colorValue
  Color? get color => colorValue != null ? Color(colorValue!) : null;

  /// Validation
  bool get isValid => name.isNotEmpty && name.length <= maxNameLength;

  @override
  List<Object?> get props => [
    uuid,
    name,
    sortOrder,
    iconCode,
    createdDate,
    type,
    colorValue,
    _visible,
  ];
}
