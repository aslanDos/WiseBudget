import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wisebuget/core/shared/widgets/input_amount/input_value.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

/// Calculator operations
enum CalculatorOperation { add, subtract, multiply, divide }

/// Shows the input amount sheet and returns the entered amount
Future<double?> showInputAmountSheet({
  required BuildContext context,
  double? initialAmount,
  String? title,
  String? currency,
  int maxDecimals = 2,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => InputAmountSheet(
      initialAmount: initialAmount,
      title: title,
      currency: currency,
      maxDecimals: maxDecimals,
    ),
  );
}

class InputAmountSheet extends StatefulWidget {
  static const double maxValue = 10e13;

  final double? initialAmount;
  final String? title;
  final String? currency;
  final int maxDecimals;

  const InputAmountSheet({
    super.key,
    this.initialAmount,
    this.title,
    this.currency,
    this.maxDecimals = 2,
  });

  @override
  State<InputAmountSheet> createState() => _InputAmountSheetState();
}

class _InputAmountSheetState extends State<InputAmountSheet> {
  late InputValue _value;
  bool _inputtingDecimal = false;
  bool _resetOnNextInput = false;
  CalculatorOperation? _currentOperation;
  InputValue? _operationCache;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _value = InputValue.fromDouble(
        widget.initialAmount!,
        maxDecimals: widget.maxDecimals,
      );
      _inputtingDecimal = _value.decimalLength > 0;
      _resetOnNextInput = true;
    } else {
      _value = const InputValue();
    }
  }

  void _reset() {
    setState(() {
      _value = const InputValue();
      _inputtingDecimal = false;
      _resetOnNextInput = false;
      _currentOperation = null;
      _operationCache = null;
    });
  }

  void _insertDigit(int digit) {
    if (_resetOnNextInput) {
      _value = const InputValue();
      _inputtingDecimal = false;
      _resetOnNextInput = false;
    }

    setState(() {
      if (_inputtingDecimal) {
        if (_value.decimalLength < widget.maxDecimals) {
          _value = _value.appendDecimal(digit, maxDecimals: widget.maxDecimals);
        }
      } else {
        final newValue = _value.appendWhole(digit);
        if (newValue.currentAmount <= InputAmountSheet.maxValue) {
          _value = newValue;
        }
      }
    });
  }

  void _removeDigit() {
    if (_resetOnNextInput) {
      _reset();
      return;
    }

    setState(() {
      if (_inputtingDecimal) {
        if (_value.decimalLength > 0) {
          _value = _value.removeDecimal();
        } else {
          _inputtingDecimal = false;
        }
      } else {
        _value = _value.removeWhole();
      }
    });
  }

  void _decimalMode() {
    if (_resetOnNextInput) {
      _value = const InputValue();
      _resetOnNextInput = false;
    }
    setState(() {
      _inputtingDecimal = true;
    });
  }

  void _setCalculatorOperation(CalculatorOperation op) {
    setState(() {
      if (_operationCache != null &&
          _currentOperation != null &&
          !_resetOnNextInput) {
        _evaluateCalculation();
      }
      _currentOperation = op;
      _operationCache = _value;
      _resetOnNextInput = true;
    });
  }

  void _evaluateCalculation() {
    if (_operationCache == null || _currentOperation == null) return;

    setState(() {
      switch (_currentOperation!) {
        case CalculatorOperation.add:
          _value = _operationCache!.add(_value);
          break;
        case CalculatorOperation.subtract:
          _value = _operationCache!.subtract(_value);
          break;
        case CalculatorOperation.multiply:
          _value = _operationCache!.multiply(_value);
          break;
        case CalculatorOperation.divide:
          _value = _operationCache!.divide(_value);
          break;
      }
      _inputtingDecimal = _value.decimalLength > 0;
      _operationCache = null;
      _currentOperation = null;
      _resetOnNextInput = true;
    });
  }

  void _save() {
    if (_currentOperation != null && !_resetOnNextInput) {
      _evaluateCalculation();
    }
    Navigator.pop(context, _value.currentAmount);
  }

  String get _displayAmount {
    final text = _value.toString();
    if (_inputtingDecimal && !text.contains('.')) {
      return '$text.';
    }
    return text;
  }

  // Calculate the preview result based on current operation
  String get _previewResult {
    if (_currentOperation == null ||
        _operationCache == null ||
        _resetOnNextInput) {
      return _operationCache?.toString() ?? _displayAmount;
    }

    InputValue result;
    switch (_currentOperation!) {
      case CalculatorOperation.add:
        result = _operationCache!.add(_value);
        break;
      case CalculatorOperation.subtract:
        result = _operationCache!.subtract(_value);
        break;
      case CalculatorOperation.multiply:
        result = _operationCache!.multiply(_value);
        break;
      case CalculatorOperation.divide:
        result = _operationCache!.divide(_value);
        break;
    }
    return result.toString();
  }

  String _operationSymbol(CalculatorOperation op) {
    switch (op) {
      case CalculatorOperation.add:
        return '+';
      case CalculatorOperation.subtract:
        return '-';
      case CalculatorOperation.multiply:
        return '×';
      case CalculatorOperation.divide:
        return '÷';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(0x40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            if (widget.title != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  widget.title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Amount display
            _buildAmountDisplay(context),

            // Numpad
            _buildNumpad(context),

            SizedBox(height: bottomPadding > 0 ? 8 : 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build expression string when in calculator mode
    String? expressionText;
    if (_currentOperation != null && _operationCache != null) {
      if (_resetOnNextInput) {
        expressionText =
            '$_operationCache ${_operationSymbol(_currentOperation!)}';
      } else {
        expressionText =
            '$_operationCache ${_operationSymbol(_currentOperation!)} $_displayAmount';
      }
    }

    // Show preview result when in calculator mode, otherwise current input
    final displayValue = _currentOperation != null
        ? _previewResult
        : _displayAmount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // Amount with currency on the right
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: Text(
                    displayValue,
                    key: ValueKey(displayValue),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.currency ?? '\$',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Show expression as a chip at the bottom
          if (expressionText != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  expressionText,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumpad(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Row 1: 1, 2, 3, +
          Row(
            children: [
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(1),
                  child: const Text('1'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(2),
                  child: const Text('2'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(3),
                  child: const Text('3'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CalculatorButton(
                  operation: CalculatorOperation.add,
                  currentOperation: _currentOperation,
                  onTap: _setCalculatorOperation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: 4, 5, 6, -
          Row(
            children: [
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(4),
                  child: const Text('4'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(5),
                  child: const Text('5'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(6),
                  child: const Text('6'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CalculatorButton(
                  operation: CalculatorOperation.subtract,
                  currentOperation: _currentOperation,
                  onTap: _setCalculatorOperation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: 7, 8, 9, ×
          Row(
            children: [
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(7),
                  child: const Text('7'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(8),
                  child: const Text('8'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(9),
                  child: const Text('9'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CalculatorButton(
                  operation: CalculatorOperation.multiply,
                  currentOperation: _currentOperation,
                  onTap: _setCalculatorOperation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 4: ., 0, backspace, ÷
          Row(
            children: [
              Expanded(
                child: _NumpadButton(
                  onTap: _decimalMode,
                  child: const Text('.'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumpadButton(
                  onTap: () => _insertDigit(0),
                  child: const Text('0'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumpadButton(
                  onTap: _removeDigit,
                  onLongPress: _reset,
                  child: const Icon(Icons.backspace_outlined, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CalculatorButton(
                  operation: CalculatorOperation.divide,
                  currentOperation: _currentOperation,
                  onTap: _setCalculatorOperation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 5: Done button (full width)
          SizedBox(
            width: double.infinity,
            child: _NumpadButton(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              onTap: _save,
              child: const Icon(Icons.check_rounded, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const _NumpadButton({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor =
        backgroundColor ?? context.c.secondary.withValues(alpha: 0.3);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap?.call();
        },
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                onLongPress?.call();
              }
            : null,
        child: SizedBox(
          height: 56,
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: foregroundColor ?? colorScheme.onSurface,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  final CalculatorOperation operation;
  final CalculatorOperation? currentOperation;
  final void Function(CalculatorOperation) onTap;

  const _CalculatorButton({
    required this.operation,
    required this.currentOperation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = operation == currentOperation;

    IconData icon;
    switch (operation) {
      case CalculatorOperation.add:
        icon = Icons.add;
        break;
      case CalculatorOperation.subtract:
        icon = Icons.remove;
        break;
      case CalculatorOperation.multiply:
        icon = Icons.close;
        break;
      case CalculatorOperation.divide:
        icon = Icons.horizontal_rule;
        break;
    }

    return _NumpadButton(
      backgroundColor: isSelected
          ? colorScheme.primaryContainer
          : context.c.secondary.withValues(alpha: 0.3),
      foregroundColor: isSelected
          ? colorScheme.onPrimaryContainer
          : colorScheme.onSurface,
      onTap: () => onTap(operation),
      child: Icon(icon, size: 22),
    );
  }
}
