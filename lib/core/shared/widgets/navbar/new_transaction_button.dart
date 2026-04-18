import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';

class NewTransactionButton extends StatefulWidget {
  final void Function(TransactionType type)? onActionTap;

  const NewTransactionButton({super.key, this.onActionTap});

  @override
  State<NewTransactionButton> createState() => _NewTransactionButtonState();
}

class _NewTransactionButtonState extends State<NewTransactionButton> {
  double _buttonRotationTurns = 0.0;

  static const _buttonOrder = [
    TransactionType.transfer,
    TransactionType.income,
    TransactionType.expense,
  ];

  @override
  Widget build(BuildContext context) {
    final navbarTheme = Theme.of(context).extension<NavbarTheme>()!;

    return PieMenu(
      theme: context.pieTheme.copyWith(
        customAngle: 90.0,
        customAngleDiff: 48.0,
        radius: 100.0,
        customAngleAnchor: PieAnchor.center,
        leftClickShowsMenu: true,
        rightClickShowsMenu: true,
        regularPressShowsMenu: true,
        longPressDuration: Duration.zero,
      ),
      onToggle: onToggle,
      actions: _buttonOrder
          .map(
            (type) => PieAction(
              tooltip: Text(type.label),
              onSelect: () => widget.onActionTap?.call(type),
              child: Icon(type.icon, size: 24.0),
              buttonTheme: PieButtonTheme(
                backgroundColor: type.backgroundColor,
                iconColor: type.backgroundColor,
              ),
              buttonThemeHovered: PieButtonTheme(
                backgroundColor: type.backgroundColor,
                iconColor: type.backgroundColor,
              ),
            ),
          )
          .toList(),
      child: Container(
        width: NavbarTheme.centerButtonSize,
        height: NavbarTheme.centerButtonSize,
        decoration: BoxDecoration(
          color: navbarTheme.transactionButtonBackgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: navbarTheme.transactionButtonBackgroundColor.withAlpha(
                0x40,
              ),
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: _buttonRotationTurns,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          child: Icon(
            AppIcons.add,
            color: navbarTheme.transactionButtonForegroundColor,
            size: 28.0,
          ),
        ),
      ),
    );
  }

  void onToggle(bool toggled) {
    _buttonRotationTurns = toggled ? 0.125 : 0.25;
    setState(() {});
  }
}
