import 'package:flutter/material.dart';

class ColoredIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;

  /// Defaults to [color] with 20% opacity if not provided.
  final Color? backgroundColor;

  final double size;
  final double padding;
  final double borderRadius;

  const ColoredIconBox({
    super.key,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.size = 18.0,
    this.padding = 6.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withAlpha(0x33),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
