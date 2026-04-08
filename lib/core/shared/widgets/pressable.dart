import 'package:flutter/material.dart';

class Pressable extends StatefulWidget {
  final Color? color;
  final Widget child;
  final VoidCallback? onTap;

  const Pressable({super.key, this.color, required this.child, this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        child: InkWell(
          onTap: widget.onTap,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),

          child: widget.child,
        ),
      ),
    );
  }
}
