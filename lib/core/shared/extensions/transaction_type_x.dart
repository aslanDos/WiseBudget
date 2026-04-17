import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/app_colors.dart';

extension TransactionTypeUI on TransactionType {
  String get label => switch (this) {
    TransactionType.income => 'Income',
    TransactionType.expense => 'Expense',
    TransactionType.transfer => 'Transfer',
  };

  IconData get icon => switch (this) {
    TransactionType.income => AppIcons.arrowDownRight,
    TransactionType.expense => AppIcons.arrowUpleft,
    TransactionType.transfer => AppIcons.arrowUpDown,
  };

  Color get backgroundColor => switch (this) {
    TransactionType.income => AppColors.green,
    TransactionType.expense => AppColors.red,
    TransactionType.transfer => AppColors.blue,
  };
}
