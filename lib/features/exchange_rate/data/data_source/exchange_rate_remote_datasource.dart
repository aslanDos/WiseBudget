import 'package:wisebuget/core/services/network_service.dart';
import 'package:wisebuget/features/exchange_rate/data/model/exchange_rate_model.dart';

abstract class ExchangeRateRemoteDataSource {
  Future<ExchangeRateModel> fetchRate(String from, String to, DateTime date);
}

/// Uses Frankfurter.app (ECB data, no API key required).
/// Supports ~33 major currencies. For exotic currencies (e.g. KZT),
/// swap this implementation with a provider that covers them.
class FrankfurterRemoteDataSource implements ExchangeRateRemoteDataSource {
  FrankfurterRemoteDataSource({required this.networkService});

  final NetworkService networkService;
  static const _baseUrl = 'https://api.frankfurter.app';

  @override
  Future<ExchangeRateModel> fetchRate(
    String from,
    String to,
    DateTime date,
  ) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final today = DateTime.now();
    final isToday = dateOnly.year == today.year &&
        dateOnly.month == today.month &&
        dateOnly.day == today.day;

    final dateStr =
        '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
    final endpoint = isToday ? 'latest' : dateStr;

    final data = await networkService.get(
      '$_baseUrl/$endpoint',
      queryParams: {'from': from, 'to': to},
    );

    final rates = data['rates'] as Map<String, dynamic>;
    if (!rates.containsKey(to)) {
      throw Exception('Rate for $to not found in response');
    }

    return ExchangeRateModel(
      pairKey: '${from}_$to',
      fromCurrency: from,
      toCurrency: to,
      rate: (rates[to] as num).toDouble(),
      date: DateTime.parse(data['date'] as String),
      fetchedAt: DateTime.now(),
    );
  }
}
