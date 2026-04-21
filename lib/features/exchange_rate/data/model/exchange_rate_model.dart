import 'package:objectbox/objectbox.dart';
import 'package:wisebuget/features/exchange_rate/domain/entity/exchange_rate_entity.dart';

@Entity()
class ExchangeRateModel {
  @Id()
  int id = 0;

  /// e.g. "USD_KZT"
  @Index()
  String pairKey;

  String fromCurrency;
  String toCurrency;
  double rate;

  @Property(type: PropertyType.date)
  @Index()
  DateTime date;

  @Property(type: PropertyType.date)
  DateTime fetchedAt;

  ExchangeRateModel({
    this.id = 0,
    required this.pairKey,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.date,
    required this.fetchedAt,
  });

  ExchangeRateEntity toEntity() {
    return ExchangeRateEntity(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      rate: rate,
      date: date,
      fetchedAt: fetchedAt,
    );
  }

  factory ExchangeRateModel.fromEntity(ExchangeRateEntity entity) {
    return ExchangeRateModel(
      pairKey: entity.pairKey,
      fromCurrency: entity.fromCurrency,
      toCurrency: entity.toCurrency,
      rate: entity.rate,
      date: entity.date,
      fetchedAt: entity.fetchedAt,
    );
  }
}
