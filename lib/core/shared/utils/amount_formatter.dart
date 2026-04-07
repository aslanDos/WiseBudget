/// Utility class for formatting monetary amounts for display.
///
/// Provides consistent formatting across the app, handling:
/// - Removing unnecessary decimal places
/// - Formatting large numbers
/// - Sign prefixes for income/expense
class AmountFormatter {
  const AmountFormatter._();

  /// Formats amount for display, removing unnecessary trailing zeros.
  ///
  /// Examples:
  /// - 100.0 → "100"
  /// - 100.50 → "100.5"
  /// - 100.05 → "100.05"
  /// - 0.0 → "0"
  static String format(double amount) {
    if (amount == 0) return '0';

    // If it's a whole number, show without decimals
    if (amount == amount.truncate()) {
      return amount.truncate().toString();
    }

    // Otherwise format to 2 decimal places and trim trailing zeros
    return amount
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Formats amount with a sign prefix.
  ///
  /// [isPositive] determines whether to show + or - prefix.
  static String formatWithSign(double amount, {required bool isPositive}) {
    final formatted = format(amount);
    final prefix = isPositive ? '+' : '-';
    return '$prefix$formatted';
  }

  /// Formats amount with currency symbol.
  ///
  /// [currencySymbol] is placed before the amount.
  static String formatWithCurrency(double amount, String currencySymbol) {
    return '$currencySymbol${format(amount)}';
  }

  /// Formats amount with both sign and currency.
  static String formatWithSignAndCurrency(
    double amount,
    String currencySymbol, {
    required bool isPositive,
  }) {
    final formatted = format(amount);
    final prefix = isPositive ? '+' : '-';
    return '$prefix$currencySymbol$formatted';
  }

  /// Formats amount in compact form for large numbers.
  ///
  /// Examples:
  /// - 1000 → "1K"
  /// - 1500000 → "1.5M"
  static String formatCompact(double amount) {
    if (amount.abs() >= 1000000) {
      final value = amount / 1000000;
      return '${format(value)}M';
    }

    if (amount.abs() >= 1000) {
      final value = amount / 1000;
      return '${format(value)}K';
    }

    return format(amount);
  }

  /// Parses a formatted string back to double.
  ///
  /// Handles strings with currency symbols and signs.
  static double? parse(String text) {
    // Remove common currency symbols and whitespace
    final cleaned = text.replaceAll(RegExp(r'[^\d.+-]'), '').trim();

    if (cleaned.isEmpty) return null;

    return double.tryParse(cleaned);
  }
}
