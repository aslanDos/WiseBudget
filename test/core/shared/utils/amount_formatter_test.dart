import 'package:flutter_test/flutter_test.dart';
import 'package:wisebuget/core/shared/utils/amount_formatter.dart';

void main() {
  group('AmountFormatter', () {
    group('format', () {
      test('returns "0" for zero', () {
        expect(AmountFormatter.format(0), '0');
        expect(AmountFormatter.format(0.0), '0');
      });

      test('returns whole number without decimals', () {
        expect(AmountFormatter.format(100.0), '100');
        expect(AmountFormatter.format(1000.0), '1000');
        expect(AmountFormatter.format(1.0), '1');
      });

      test('trims trailing zeros', () {
        expect(AmountFormatter.format(100.50), '100.5');
        expect(AmountFormatter.format(100.10), '100.1');
        expect(AmountFormatter.format(99.90), '99.9');
      });

      test('keeps significant decimals', () {
        expect(AmountFormatter.format(100.05), '100.05');
        expect(AmountFormatter.format(100.01), '100.01');
        expect(AmountFormatter.format(0.99), '0.99');
      });

      test('handles small decimals', () {
        expect(AmountFormatter.format(0.5), '0.5');
        expect(AmountFormatter.format(0.05), '0.05');
      });

      test('handles negative numbers', () {
        expect(AmountFormatter.format(-100.0), '-100');
        expect(AmountFormatter.format(-100.50), '-100.5');
      });
    });

    group('formatWithSign', () {
      test('adds + for positive amounts', () {
        expect(
          AmountFormatter.formatWithSign(100, isPositive: true),
          '+100',
        );
      });

      test('adds - for negative display', () {
        expect(
          AmountFormatter.formatWithSign(100, isPositive: false),
          '-100',
        );
      });

      test('formats decimals correctly with sign', () {
        expect(
          AmountFormatter.formatWithSign(100.50, isPositive: true),
          '+100.5',
        );
        expect(
          AmountFormatter.formatWithSign(100.50, isPositive: false),
          '-100.5',
        );
      });
    });

    group('formatWithCurrency', () {
      test('prepends currency symbol', () {
        expect(AmountFormatter.formatWithCurrency(100, '\$'), '\$100');
        expect(AmountFormatter.formatWithCurrency(100.50, '€'), '€100.5');
      });

      test('handles zero with currency', () {
        expect(AmountFormatter.formatWithCurrency(0, '\$'), '\$0');
      });
    });

    group('formatWithSignAndCurrency', () {
      test('combines sign and currency', () {
        expect(
          AmountFormatter.formatWithSignAndCurrency(
            100,
            '\$',
            isPositive: true,
          ),
          '+\$100',
        );
        expect(
          AmountFormatter.formatWithSignAndCurrency(
            100.50,
            '€',
            isPositive: false,
          ),
          '-€100.5',
        );
      });
    });

    group('formatCompact', () {
      test('returns regular format for small numbers', () {
        expect(AmountFormatter.formatCompact(100), '100');
        expect(AmountFormatter.formatCompact(999), '999');
      });

      test('uses K suffix for thousands', () {
        expect(AmountFormatter.formatCompact(1000), '1K');
        expect(AmountFormatter.formatCompact(1500), '1.5K');
        expect(AmountFormatter.formatCompact(10000), '10K');
        expect(AmountFormatter.formatCompact(50500), '50.5K');
      });

      test('uses M suffix for millions', () {
        expect(AmountFormatter.formatCompact(1000000), '1M');
        expect(AmountFormatter.formatCompact(1500000), '1.5M');
        expect(AmountFormatter.formatCompact(10000000), '10M');
      });

      test('handles negative numbers in compact format', () {
        expect(AmountFormatter.formatCompact(-1000), '-1K');
        expect(AmountFormatter.formatCompact(-1500000), '-1.5M');
      });
    });

    group('parse', () {
      test('parses simple numbers', () {
        expect(AmountFormatter.parse('100'), 100.0);
        expect(AmountFormatter.parse('100.50'), 100.50);
      });

      test('parses numbers with currency symbols', () {
        expect(AmountFormatter.parse('\$100'), 100.0);
        expect(AmountFormatter.parse('€100.50'), 100.50);
      });

      test('parses numbers with sign', () {
        expect(AmountFormatter.parse('+100'), 100.0);
        expect(AmountFormatter.parse('-100'), -100.0);
      });

      test('returns null for empty string', () {
        expect(AmountFormatter.parse(''), isNull);
      });

      test('returns null for non-numeric string', () {
        expect(AmountFormatter.parse('abc'), isNull);
      });

      test('handles whitespace', () {
        expect(AmountFormatter.parse('  100  '), 100.0);
      });
    });
  });
}
