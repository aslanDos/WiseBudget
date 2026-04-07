import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';

/// A navigation bar button with an animated dot indicator for active state.
///
/// Features:
/// - Color transition between active and inactive states
/// - Animated dot indicator underneath active icon
/// - Smooth 300ms animation for all transitions
class NavbarButton extends StatelessWidget {
  final IconData icon;
  final int index;
  final int activeIndex;
  final ValueChanged<int> onTap;

  bool get isActive => index == activeIndex;

  const NavbarButton({
    super.key,
    required this.icon,
    required this.index,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onTap(index),
          customBorder: const StadiumBorder(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: SizedBox(
            height: NavbarTheme.height,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey('$index-$isActive'),
                color: isActive
                    ? navbarTheme.activeIconColor
                    : navbarTheme.inactiveIconColor,
                size: 24.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
