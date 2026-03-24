import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/amount_display.dart';

class TransactionAmountSection extends StatelessWidget {
  final String amount;
  final TransactionType type;
  final VoidCallback onTap;

  const TransactionAmountSection({
    super.key,
    required this.amount,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AmountDisplay(amount: amount, type: type),
    );
  }
}
