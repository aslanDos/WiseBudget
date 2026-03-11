import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final EdgeInsets padding;
  final double? width;

  const Button({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading = false,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : (icon ?? const SizedBox.shrink()),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}

class AppOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color? foregroundColor;
  final bool isLoading;
  final EdgeInsets padding;
  final double? width;

  const AppOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.foregroundColor,
    this.isLoading = false,
    this.padding = const EdgeInsets.all(16.0),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : (icon ?? const SizedBox.shrink()),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: padding,
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}
