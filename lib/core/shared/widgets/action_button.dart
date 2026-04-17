import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class ActionButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final Border? border;

  const ActionButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.iconSize = 20,
    this.backgroundColor,
    this.iconColor,
    this.border,
  });

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(12),
          color: widget.backgroundColor ?? context.c.surfaceContainer,
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.iconColor ?? context.c.onSurface,
          ),
        ),
      ),
    );
  }
}
