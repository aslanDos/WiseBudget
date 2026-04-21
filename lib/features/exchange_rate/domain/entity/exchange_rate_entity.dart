import 'package:equatable/equatable.dart';

class ExchangeRateEntity extends Equatable {
  const ExchangeRateEntity({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.date,
    required this.fetchedAt,
  });

  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final DateTime date;       // truncated to date only (year/month/day)
  final DateTime fetchedAt;

  String get pairKey => '${fromCurrency}_$toCurrency';

  bool get isStale =>
      DateTime.now().difference(fetchedAt).inHours >= 24;

  @override
  List<Object?> get props => [fromCurrency, toCurrency, date];
}
