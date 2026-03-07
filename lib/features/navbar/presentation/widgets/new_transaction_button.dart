import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/navbar_theme.dart';

class NewTransactionButton extends StatelessWidget {
  const NewTransactionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final NavbarTheme navbarTheme = Theme.of(context).extension<NavbarTheme>()!;
    return Material(
      color: navbarTheme.transactionButtonBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: .circular(32.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Icon(
          AppIcons.add,
          fill: 0.0,
          color: navbarTheme.backgroundColor,
          weight: 900.0,
        ),
      ),
    );
  }
}
