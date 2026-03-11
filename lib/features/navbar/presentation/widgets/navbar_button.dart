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
          splashColor: navbarTheme.activeIconColor.withAlpha(0x1A),
          highlightColor: navbarTheme.activeIconColor.withAlpha(0x0D),
          child: SizedBox(
            height: NavbarTheme.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with color animation
                AnimatedSwitcher(
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

                const SizedBox(height: 4.0),

                // Dot indicator with scale animation
                AnimatedScale(
                  scale: isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    width: NavbarTheme.indicatorSize,
                    height: NavbarTheme.indicatorSize,
                    decoration: BoxDecoration(
                      color: navbarTheme.indicatorColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
