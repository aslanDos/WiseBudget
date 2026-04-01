import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

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
    this.spacing = 10.0,
    this.buttonHeight = 52.0,
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
      children: keys.asMap().entries.map((entry) {
        final index = entry.key;
        final key = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : spacing / 2,
              right: index == keys.length - 1 ? 0 : spacing / 2,
            ),
            child: _NumpadKey(
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
            padding: EdgeInsets.only(right: spacing / 2),
            child: _NumpadKey(
              label: '.',
              height: buttonHeight,
              onPressed: () => onKeyPressed('.'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: _NumpadKey(
              label: '0',
              height: buttonHeight,
              onPressed: () => onKeyPressed('0'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: spacing / 2),
            child: _NumpadKey(
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

class _NumpadKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double height;

  const _NumpadKey({
    this.label,
    this.icon,
    this.onPressed,
    this.onLongPress,
    this.height = 52.0,
  }) : assert(label != null || icon != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: context.c.secondary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed?.call();
        },
        onLongPress: onLongPress != null
            ? () {
                HapticFeedback.mediumImpact();
                onLongPress?.call();
              }
            : null,
        splashColor: colorScheme.primary.withAlpha(0x1A),
        highlightColor: colorScheme.primary.withAlpha(0x0D),
        child: SizedBox(
          height: height,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 22.0, color: colorScheme.onSurface)
                : Text(
                    label!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
