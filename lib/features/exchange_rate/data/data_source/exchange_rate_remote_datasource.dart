import 'package:wisebuget/core/services/network_service.dart';
import 'package:wisebuget/features/exchange_rate/data/model/exchange_rate_model.dart';

abstract class ExchangeRateRemoteDataSource {
  Future<ExchangeRateModel> fetchRate(String from, String to, DateTime date);
}

/// Uses open.er-api.com (free, no API key, broad currency support including KZT).
/// Returns latest rates only — historical date parameter is stored but not queried.
class FrankfurterRemoteDataSource implements ExchangeRateRemoteDataSource {
  FrankfurterRemoteDataSource({required this.networkService});

  final NetworkService networkService;
  static const _baseUrl = 'https://open.er-api.com/v6/latest';

  @override
  Future<ExchangeRateModel> fetchRate(
    String from,
    String to,
    DateTime date,
  ) async {
    final data = await networkService.get('$_baseUrl/$from');

    if (data['result'] != 'success') {
      throw Exception('Exchange rate API returned: ${data['result']}');
    }

    final rates = data['rates'] as Map<String, dynamic>;
    if (!rates.containsKey(to)) {
      throw Exception('Rate for $to not found in response');
    }

    final dateOnly = DateTime(date.year, date.month, date.day);

    return ExchangeRateModel(
      pairKey: '${from}_$to',
      fromCurrency: from,
      toCurrency: to,
      rate: (rates[to] as num).toDouble(),
      date: dateOnly,
      fetchedAt: DateTime.now(),
    );
  }
}
