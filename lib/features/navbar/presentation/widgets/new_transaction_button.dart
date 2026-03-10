import 'package:flutter/material.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return PieMenu(
      theme: PieTheme(
        tooltipTextStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
        overlayColor: colorScheme.scrim.withValues(alpha: 0.5),
        pointerColor: Colors.transparent,
        buttonTheme: PieButtonTheme(
          backgroundColor: colorScheme.surface,
          iconColor: colorScheme.onSurface,
        ),
        buttonThemeHovered: PieButtonTheme(
          backgroundColor: colorScheme.primaryContainer,
          iconColor: colorScheme.onPrimaryContainer,
        ),
        customAngle: 135.0,
        customAngleDiff: 45.0,
        radius: 80.0,
        spacing: 6.0,
        customAngleAnchor: PieAnchor.center,
        leftClickShowsMenu: true,
        rightClickShowsMenu: true,
        regularPressShowsMenu: true,
        longPressDuration: Duration.zero,
      ),
      onToggle: _onToggle,
      actions: _buttonOrder
          .map(
            (type) => PieAction(
              tooltip: Text(type.label),
              onSelect: () => widget.onActionTap?.call(type),
              child: Icon(type.icon, size: 24.0),
              buttonTheme: PieButtonTheme(
                backgroundColor: type.actionBackgroundColor(context),
                iconColor: type.actionColor(context),
              ),
              buttonThemeHovered: PieButtonTheme(
                backgroundColor: type.actionBackgroundColor(context),
                iconColor: type.actionColor(context),
              ),
            ),
          )
          .toList(),
      child: Tooltip(
        message: 'New Transaction',
        child: SizedBox(
          width: 64.0,
          height: 64.0,
          child: Material(
            color: navbarTheme.transactionButtonBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
            ),
            child: Center(
              child: AnimatedRotation(
                turns: _buttonRotationTurns,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Icon(
                  AppIcons.add,
                  color: navbarTheme.transactionButtonForegroundColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onToggle(bool toggled) {
    setState(() {
      _buttonRotationTurns = toggled ? 0.125 : 0.0;
    });
  }
}
