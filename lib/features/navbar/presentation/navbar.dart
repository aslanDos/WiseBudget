import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';
import 'package:wisebuget/features/navbar/presentation/widgets/navbar_button.dart';

class Navbar extends StatelessWidget {
  final int activeIndex;
  final Function(int i) onTap;

  const Navbar({super.key, required this.onTap, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return Container(
      constraints: BoxConstraints(maxWidth: 480.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: .circular(999.9),
        color: navbarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: const Color(0x05000000),
            blurRadius: 16.0,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: const Color(0x10000000),
            blurRadius: 4.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: .spaceEvenly,
        children: [
          NavbarButton(
            index: 0,
            icon: AppIcons.circle,
            onTap: onTap,
            activeIndex: activeIndex,
          ),
          NavbarButton(
            index: 1,
            icon: AppIcons.wallet,
            onTap: onTap,
            activeIndex: activeIndex,
          ),
          NavbarButton(
            index: 2,
            icon: AppIcons.chart,
            onTap: onTap,
            activeIndex: activeIndex,
          ),
          NavbarButton(
            index: 3,
            icon: AppIcons.briefCase,
            onTap: onTap,
            activeIndex: activeIndex,
          ),
        ],
      ),
    );
  }
}
