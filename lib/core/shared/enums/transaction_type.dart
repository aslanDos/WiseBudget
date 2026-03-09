import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum TransactionType {
  transfer("transfer"),
  income("income"),
  expense("expense");

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
        TransactionType.income => LucideIcons.arrowDownLeft,
        TransactionType.expense => LucideIcons.arrowUpRight,
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
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      TransactionType.income => const Color(0xFFA6E3A1), // green
      TransactionType.expense => const Color(0xFFF38BA8), // red
      TransactionType.transfer => colorScheme.secondary,
    };
  }
}
