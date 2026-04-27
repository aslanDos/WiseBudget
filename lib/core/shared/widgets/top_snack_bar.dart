import 'package:flutter/material.dart';

class TopSnackBarController {
  OverlayEntry? _entry;
  int _serial = 0;

  void showError(BuildContext context, String message) {
    _entry?.remove();

    final colors = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final topPadding = MediaQuery.paddingOf(context).top;
    final serial = ++_serial;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + 14,
        left: 16,
        right: 16,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: _TopSnackBar(
              message: message,
              colors: colors,
              textStyle: textStyle,
              onDismissed: () {
                if (_serial != serial) return;
                entry.remove();
                if (_entry == entry) _entry = null;
              },
            ),
          ),
        ),
      ),
    );

    _entry = entry;
    Overlay.of(context).insert(entry);
  }

  void dispose() {
    _entry?.remove();
    _entry = null;
  }
}

class _TopSnackBar extends StatefulWidget {
  const _TopSnackBar({
    required this.message,
    required this.colors,
    required this.textStyle,
    required this.onDismissed,
  });

  final String message;
  final ColorScheme colors;
  final TextStyle? textStyle;
  final VoidCallback onDismissed;

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 180),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.28),
      end: Offset.zero,
    ).animate(curved);

    _runAnimation();
  }

  Future<void> _runAnimation() async {
    await _controller.forward();
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.colors.errorContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: widget.colors.error.withAlpha(0x2E)),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.shadow.withAlpha(0x24),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: widget.colors.error.withAlpha(0x16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: widget.colors.error,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: widget.textStyle?.copyWith(
                          color: widget.colors.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
