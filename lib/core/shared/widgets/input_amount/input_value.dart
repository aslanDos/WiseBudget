import 'dart:math';

/// Represents an input value with separate whole and decimal parts
/// for precise decimal handling during input.
class InputValue implements Comparable<InputValue> {
  static const int defaultMaxDecimals = 2;

  final int wholePart;
  final int decimalPart;
  final bool isNegative;
  final int _decimalLeadingZeroes;

  const InputValue({
    this.wholePart = 0,
    this.decimalPart = 0,
    this.isNegative = false,
    int decimalLeadingZeroes = 0,
  }) : _decimalLeadingZeroes = decimalLeadingZeroes;

  /// Creates an InputValue from a double
  factory InputValue.fromDouble(double value, {int maxDecimals = defaultMaxDecimals}) {
    if (value == 0) return const InputValue();

    final isNegative = value < 0;
    final absValue = value.abs();
    final wholePart = absValue.truncate();

    // Extract decimal part with precision handling
    final decimalStr = absValue.toStringAsFixed(maxDecimals);
    final dotIndex = decimalStr.indexOf('.');
    if (dotIndex == -1) {
      return InputValue(wholePart: wholePart, isNegative: isNegative);
    }

    final decimalPartStr = decimalStr.substring(dotIndex + 1);
    // Count leading zeroes
    int leadingZeroes = 0;
    for (var char in decimalPartStr.split('')) {
      if (char == '0') {
        leadingZeroes++;
      } else {
        break;
      }
    }

    // Remove trailing zeroes
    final trimmed = decimalPartStr.replaceAll(RegExp(r'0+$'), '');
    final decimalPart = trimmed.isEmpty ? 0 : int.parse(trimmed);

    // Recalculate leading zeroes for trimmed value
    final actualLeadingZeroes = decimalPart == 0 ? 0 : leadingZeroes;

    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart,
      isNegative: isNegative,
      decimalLeadingZeroes: actualLeadingZeroes,
    );
  }

  /// The number of decimal digits
  int get decimalLength {
    if (decimalPart == 0) return 0;
    return _decimalLeadingZeroes + decimalPart.toString().length;
  }

  /// Converts to double
  double get currentAmount {
    final decimal = decimalPart * pow(10.0, -decimalLength);
    return (wholePart + decimal) * (isNegative ? -1 : 1);
  }

  /// Whether the value is zero
  bool get isZero => wholePart == 0 && decimalPart == 0;

  /// Appends a digit to the whole part
  InputValue appendWhole(int digit) {
    if (digit < 0 || digit > 9) return this;
    final newWhole = wholePart * 10 + digit;
    return InputValue(
      wholePart: newWhole,
      decimalPart: decimalPart,
      isNegative: isNegative,
      decimalLeadingZeroes: _decimalLeadingZeroes,
    );
  }

  /// Appends a digit to the decimal part
  InputValue appendDecimal(int digit, {int maxDecimals = defaultMaxDecimals}) {
    if (digit < 0 || digit > 9) return this;
    if (decimalLength >= maxDecimals) return this;

    if (decimalPart == 0 && digit == 0) {
      // Adding a leading zero to decimal
      return InputValue(
        wholePart: wholePart,
        decimalPart: 0,
        isNegative: isNegative,
        decimalLeadingZeroes: _decimalLeadingZeroes + 1,
      );
    }

    final newDecimal = decimalPart * 10 + digit;
    return InputValue(
      wholePart: wholePart,
      decimalPart: newDecimal,
      isNegative: isNegative,
      decimalLeadingZeroes: _decimalLeadingZeroes,
    );
  }

  /// Removes the last digit from the whole part
  InputValue removeWhole() {
    if (wholePart == 0) return this;
    return InputValue(
      wholePart: wholePart ~/ 10,
      decimalPart: decimalPart,
      isNegative: isNegative,
      decimalLeadingZeroes: _decimalLeadingZeroes,
    );
  }

  /// Removes the last digit from the decimal part
  InputValue removeDecimal() {
    if (_decimalLeadingZeroes > 0 && decimalPart == 0) {
      return InputValue(
        wholePart: wholePart,
        decimalPart: 0,
        isNegative: isNegative,
        decimalLeadingZeroes: _decimalLeadingZeroes - 1,
      );
    }
    if (decimalPart == 0) return this;

    final newDecimal = decimalPart ~/ 10;
    return InputValue(
      wholePart: wholePart,
      decimalPart: newDecimal,
      isNegative: isNegative,
      decimalLeadingZeroes: _decimalLeadingZeroes,
    );
  }

  /// Returns the negated value
  InputValue negated() {
    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart,
      isNegative: !isNegative,
      decimalLeadingZeroes: _decimalLeadingZeroes,
    );
  }

  /// Returns the absolute value
  InputValue abs() {
    if (!isNegative) return this;
    return InputValue(
      wholePart: wholePart,
      decimalPart: decimalPart,
      isNegative: false,
      decimalLeadingZeroes: _decimalLeadingZeroes,
    );
  }

  // Arithmetic operations
  InputValue add(InputValue other) {
    return InputValue.fromDouble(currentAmount + other.currentAmount);
  }

  InputValue subtract(InputValue other) {
    return InputValue.fromDouble(currentAmount - other.currentAmount);
  }

  InputValue multiply(InputValue other) {
    return InputValue.fromDouble(currentAmount * other.currentAmount);
  }

  InputValue divide(InputValue other) {
    if (other.currentAmount == 0) return this;
    return InputValue.fromDouble(currentAmount / other.currentAmount);
  }

  @override
  int compareTo(InputValue other) {
    return currentAmount.compareTo(other.currentAmount);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InputValue && other.currentAmount == currentAmount;
  }

  @override
  int get hashCode => currentAmount.hashCode;

  @override
  String toString() {
    if (decimalPart == 0 && _decimalLeadingZeroes == 0) {
      return '${isNegative ? '-' : ''}$wholePart';
    }
    final decimalStr = '0' * _decimalLeadingZeroes + decimalPart.toString();
    return '${isNegative ? '-' : ''}$wholePart.$decimalStr';
  }
}
