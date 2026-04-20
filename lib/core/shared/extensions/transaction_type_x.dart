import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/app_colors.dart';

extension TransactionTypeUI on TransactionType {
  String get label => switch (this) {
    TransactionType.income => 'Income',
    TransactionType.expense => 'Expense',
    TransactionType.transfer => 'Transfer',
    TransactionType.adjustment => 'Adjustment',
  };

  String l10nLabel(AppLocalizations l10n) => switch (this) {
    TransactionType.income => l10n.income,
    TransactionType.expense => l10n.expense,
    TransactionType.transfer => l10n.transfer,
    TransactionType.adjustment => l10n.adjustment,
  };

  IconData get icon => switch (this) {
    TransactionType.income => AppIcons.arrowDownRight,
    TransactionType.expense => AppIcons.arrowUpleft,
    TransactionType.transfer => AppIcons.arrowUpDown,
    TransactionType.adjustment => AppIcons.scales,
  };

  Color get backgroundColor => switch (this) {
    TransactionType.income => AppColors.green,
    TransactionType.expense => AppColors.red,
    TransactionType.transfer => AppColors.blue,
    TransactionType.adjustment => AppColors.blue,
  };
}
