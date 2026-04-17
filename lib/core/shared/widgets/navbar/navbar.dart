import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/navbar/navbar_button.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';

/// A floating navigation bar with a center gap for the transaction button.
///
/// Layout structure:
/// ```
/// [Button][Button]  [GAP]  [Button][Button]
/// ```
/// The gap is reserved for the floating center button (NewTransactionButton)
/// which is positioned separately in the parent Stack.
class Navbar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTap;

  const Navbar({super.key, required this.onTap, this.activeIndex = 0});

  @override
  Widget build(BuildContext context) {
    final navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return Container(
      height: NavbarTheme.height,
      constraints: const BoxConstraints(maxWidth: 480.0),
      decoration: BoxDecoration(
        color: navbarTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: navbarTheme.inactiveIconColor.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Left section (2 buttons)
          Expanded(
            child: Row(
              children: [
                NavbarButton(
                  index: 0,
                  icon: AppIcons.circle,
                  label: 'Home',
                  activeIndex: activeIndex,
                  onTap: onTap,
                ),
                NavbarButton(
                  index: 1,
                  icon: AppIcons.wallet,
                  label: 'Accounts',
                  activeIndex: activeIndex,
                  onTap: onTap,
                ),
              ],
            ),
          ),

          // Center gap for floating button
          const SizedBox(width: NavbarTheme.centerGapWidth),

          // Right section (2 buttons)
          Expanded(
            child: Row(
              children: [
                NavbarButton(
                  index: 2,
                  icon: AppIcons.chart,
                  label: 'Analytics',
                  activeIndex: activeIndex,
                  onTap: onTap,
                ),
                NavbarButton(
                  index: 3,
                  icon: AppIcons.piggyBank,
                  label: 'Budget',
                  activeIndex: activeIndex,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
