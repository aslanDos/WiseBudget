import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';

class NavbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int activeIndex;
  final ValueChanged<int> onTap;

  bool get isActive => index == activeIndex;

  const NavbarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final navbarTheme = Theme.of(context).extension<NavbarTheme>()!;
    final color = isActive
        ? navbarTheme.activeIconColor
        : navbarTheme.inactiveIconColor;

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    key: ValueKey('$index-$isActive'),
                    color: color,
                    size: 22.0,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: color,
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
