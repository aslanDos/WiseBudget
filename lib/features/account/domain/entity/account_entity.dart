import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  final String uuid;
  final String name;
  final String currency;
  final int sortOrder;
  final String iconCode;

  const AccountEntity({
    required this.uuid,
    required this.name,
    required this.currency,
    this.sortOrder = -1,
    required this.iconCode,
  });

  AccountEntity copyWith({
    String? uuid,
    String? name,
    String? currency,
    int? sortOrder,
    String? iconCode,
  }) {
    return AccountEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      sortOrder: sortOrder ?? this.sortOrder,
      iconCode: iconCode ?? this.iconCode,
    );
  }

  @override
  List<Object?> get props => [uuid, name, currency, sortOrder, iconCode];
}
