import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class CircleIconButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final Border? border;

  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.iconSize = 24,
    this.backgroundColor,
    this.iconColor,
    this.border,
  });

  @override
  State<CircleIconButton> createState() => _CircleIconButtonState();
}

class _CircleIconButtonState extends State<CircleIconButton> {
  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: widget.onTap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.c.surfaceContainer,
          border: widget.border ?? Border.all(color: context.c.onSurface),
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
