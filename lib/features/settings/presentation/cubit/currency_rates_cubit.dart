import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/services/network_service.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';

class CurrencyRatesState {
  const CurrencyRatesState({
    this.status = CubitStatus.initial,
    this.rates = const {},
    this.baseCurrency = '',
    this.lastUpdated,
  });

  final CubitStatus status;

  /// rates[code] = how many [code] equal 1 [baseCurrency]
  final Map<String, double> rates;
  final String baseCurrency;

  /// UTC timestamp from the API response (time_last_update_unix).
  final DateTime? lastUpdated;

  CurrencyRatesState copyWith({
    CubitStatus? status,
    Map<String, double>? rates,
    String? baseCurrency,
    DateTime? lastUpdated,
  }) {
    return CurrencyRatesState(
      status: status ?? this.status,
      rates: rates ?? this.rates,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Returns "1 [code] ≈ X [base]" value, or null if unknown.
  double? rateFor(String code) {
    if (code == baseCurrency) return 1.0;
    final r = rates[code];
    if (r == null || r == 0) return null;
    return 1.0 / r;
  }
}

class CurrencyRatesCubit extends Cubit<CurrencyRatesState> {
  CurrencyRatesCubit({required this.networkService})
      : super(const CurrencyRatesState());

  final NetworkService networkService;
  static const _baseUrl = 'https://open.er-api.com/v6/latest';

  Future<void> loadRates(String baseCurrency) async {
    if (state.baseCurrency == baseCurrency &&
        state.status == CubitStatus.success) {
      return;
    }

    emit(state.copyWith(
      status: CubitStatus.loading,
      baseCurrency: baseCurrency,
    ));

    try {
      final data = await networkService.get('$_baseUrl/$baseCurrency');

      if (data['result'] == 'success') {
        final raw = data['rates'] as Map<String, dynamic>;
        final rates = raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
        final unix = data['time_last_update_unix'] as int?;
        final lastUpdated = unix != null
            ? DateTime.fromMillisecondsSinceEpoch(unix * 1000, isUtc: true)
            : DateTime.now().toUtc();
        emit(state.copyWith(
          status: CubitStatus.success,
          rates: rates,
          lastUpdated: lastUpdated,
        ));
      } else {
        emit(state.copyWith(status: CubitStatus.failure));
      }
    } catch (_) {
      emit(state.copyWith(status: CubitStatus.failure));
    }
  }
}
