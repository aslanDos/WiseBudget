import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';
import 'package:wisebuget/features/navbar/presentation/widgets/navbar_button.dart';

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

  const Navbar({
    super.key,
    required this.onTap,
    this.activeIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return Container(
      height: NavbarTheme.height,
      constraints: const BoxConstraints(maxWidth: 480.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(NavbarTheme.height / 2),
        color: navbarTheme.backgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 24.0,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
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
                  activeIndex: activeIndex,
                  onTap: onTap,
                ),
                NavbarButton(
                  index: 1,
                  icon: AppIcons.wallet,
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
                  activeIndex: activeIndex,
                  onTap: onTap,
                ),
                NavbarButton(
                  index: 3,
                  icon: AppIcons.briefCase,
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
