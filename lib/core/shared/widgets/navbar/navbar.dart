import 'package:flutter/material.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
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
                  icon: activeIndex == 0 ? AppIcons.circle400 : AppIcons.circle,
                  label: context.l10n.home,
                  activeIndex: activeIndex,
                  onTap: onTap,
                ),
                NavbarButton(
                  index: 1,
                  icon: activeIndex == 1 ? AppIcons.wallet400 : AppIcons.wallet,
                  label: context.l10n.accounts,
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
                  icon: activeIndex == 2 ? AppIcons.chart400 : AppIcons.chart,
                  label: context.l10n.analytics,
                  activeIndex: activeIndex,
                  onTap: onTap,
                ),
                NavbarButton(
                  index: 3,
                  icon: activeIndex == 3
                      ? AppIcons.piggyBank400
                      : AppIcons.piggyBank,
                  label: context.l10n.budget,
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
