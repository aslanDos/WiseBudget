import 'package:flutter/material.dart';

class Numpad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback? onBackspace;
  final VoidCallback? onClear;
  final double spacing;
  final double buttonHeight;

  const Numpad({
    super.key,
    required this.onKeyPressed,
    this.onBackspace,
    this.onClear,
    this.spacing = 8.0,
    this.buttonHeight = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildRow(['1', '2', '3'], context),
        SizedBox(height: spacing),
        _buildRow(['4', '5', '6'], context),
        SizedBox(height: spacing),
        _buildRow(['7', '8', '9'], context),
        SizedBox(height: spacing),
        _buildBottomRow(context),
      ],
    );
  }

  Widget _buildRow(List<String> keys, BuildContext context) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: NumpadKey(
              label: key,
              height: buttonHeight,
              onPressed: () => onKeyPressed(key),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: NumpadKey(
              label: '.',
              height: buttonHeight,
              onPressed: () => onKeyPressed('.'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: NumpadKey(
              label: '0',
              height: buttonHeight,
              onPressed: () => onKeyPressed('0'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: NumpadKey(
              icon: Icons.backspace_outlined,
              height: buttonHeight,
              onPressed: onBackspace,
              onLongPress: onClear,
            ),
          ),
        ),
      ],
    );
  }
}

class NumpadKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double height;

  const NumpadKey({
    super.key,
    this.label,
    this.icon,
    this.onPressed,
    this.onLongPress,
    this.height = 56.0,
  }) : assert(label != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          height: height,
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, size: 24.0)
              : Text(
                  label!,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
