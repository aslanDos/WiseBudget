import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';

class AccountEntity extends Equatable {
  final String uuid;
  final String name;
  final String currency;
  final double balance;
  final int sortOrder;
  final String iconCode;
  final DateTime createdDate;
  final int? colorValue;

  /// Validation constants
  static const int maxNameLength = 48;

  /// Validation
  bool get isValid => name.isNotEmpty && name.length <= maxNameLength;

  /// Computed property - returns balance as Money value object
  Money get money => Money(balance, currency);

  /// Computed property - returns Color from colorValue
  Color? get color => colorValue != null ? Color(colorValue!) : null;

  /// Convenience getters
  bool get isEmpty => balance == 0;
  bool get isNegative => balance < 0;

  const AccountEntity({
    required this.uuid,
    required this.name,
    required this.currency,
    this.balance = 0.0,
    this.sortOrder = -1,
    required this.iconCode,
    required this.createdDate,
    this.colorValue,
  });

  AccountEntity copyWith({
    String? uuid,
    String? name,
    String? currency,
    double? balance,
    int? sortOrder,
    String? iconCode,
    DateTime? createdDate,
    int? colorValue,
  }) {
    return AccountEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      sortOrder: sortOrder ?? this.sortOrder,
      iconCode: iconCode ?? this.iconCode,
      createdDate: createdDate ?? this.createdDate,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    name,
    currency,
    balance,
    sortOrder,
    iconCode,
    createdDate,
    colorValue,
  ];
}
