import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/app_colors.dart';

enum TransactionType {
  income("income"),
  expense("expense"),
  transfer("transfer");

  final String value;

  const TransactionType(this.value);

  /// Display name for the transaction type
  String get label => switch (this) {
    TransactionType.income => 'Income',
    TransactionType.expense => 'Expense',
    TransactionType.transfer => 'Transfer',
  };

  /// Icon for the transaction type
  IconData get icon => switch (this) {
    TransactionType.income => AppIcons.arrowDownRight,
    TransactionType.expense => AppIcons.arrowUpleft,
    TransactionType.transfer => LucideIcons.arrowLeftRight,
  };

  /// Action button foreground color
  Color actionColor(BuildContext context) => switch (this) {
    TransactionType.income => Colors.white,
    TransactionType.expense => Colors.white,
    TransactionType.transfer => Colors.white,
  };

  /// Action button background color
  Color actionBackgroundColor(BuildContext context) {
    return switch (this) {
      TransactionType.income => AppColors.green, // green
      TransactionType.expense => AppColors.red, // red
      TransactionType.transfer => AppColors.blue,
    };
  }
}
