import 'package:intl/intl.dart';

class Money {
  final double amount;
  final String currency;

  static const String invalidCurrency = "";

  const Money._(this.amount, this.currency);

  /// Not a Money (invalid state)
  static const Money nam = Money._(double.nan, invalidCurrency);

  /// Zero money for a given currency
  factory Money.zero(String currency) => Money._(0.0, currency.toUpperCase());

  factory Money(double amount, String currency) {
    return Money._(amount, currency.toUpperCase());
  }

  // ============ Operations ============

  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(amount + other.amount, currency);
  }

  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(amount - other.amount, currency);
  }

  Money operator -() => Money(-amount, currency);

  Money operator *(double multiplier) => Money(amount * multiplier, currency);

  Money operator /(double divisor) => Money(amount / divisor, currency);

  // ============ Comparison ============

  /// Compare amounts. Returns 0 if currencies don't match.
  int compareTo(Money other) {
    if (currency != other.currency) return 0;
    return amount.compareTo(other.amount);
  }

  bool operator <(Money other) => compareTo(other) < 0;
  bool operator >(Money other) => compareTo(other) > 0;
  bool operator <=(Money other) => compareTo(other) <= 0;
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Money) return false;
    return amount == other.amount && currency == other.currency;
  }

  @override
  int get hashCode => Object.hashAll([amount, currency]);

  // ============ Getters ============

  bool get isNegative => amount.isNegative;
  bool get isPositive => amount > 0;
  bool get isZero => amount == 0;
  bool get isValid => currency.isNotEmpty && !amount.isNaN;

  Money abs() => Money(amount.abs(), currency);

  // ============ Formatting ============

  /// Formats money with currency symbol (e.g., "$420.69")
  String get formatted => formatMoney();

  /// Formats money compact (e.g., "$1.2M")
  String get formattedCompact => formatMoney(compact: true);

  /// Formats amount only without currency (e.g., "467,000")
  String get formattedNoMarker => formatMoney(includeCurrency: false);

  String formatMoney({
    bool includeCurrency = true,
    bool useCurrencySymbol = true,
    bool compact = false,
    bool takeAbsoluteValue = false,
    int decimalDigits = 2,
  }) {
    final num value = takeAbsoluteValue ? amount.abs() : amount;
    final String curr = includeCurrency ? currency : "";

    final String? symbol = useCurrencySymbol && includeCurrency
        ? NumberFormat.simpleCurrency(name: currency).currencySymbol
        : null;

    if (compact) {
      return NumberFormat.compactCurrency(
        name: curr,
        symbol: symbol,
        decimalDigits: decimalDigits,
      ).format(value);
    }

    return NumberFormat.currency(
      name: curr,
      symbol: symbol,
      decimalDigits: decimalDigits,
    ).format(value);
  }

  @override
  String toString() => "Money($currency $amount)";

  // ============ Private ============

  void _assertSameCurrency(Money other) {
    if (currency != other.currency) {
      throw MoneyException(
        "Cannot operate on Money of different currencies: $currency vs ${other.currency}",
      );
    }
  }
}

class MoneyException implements Exception {
  final String message;
  const MoneyException(this.message);

  @override
  String toString() => message;
}
