import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';

class AmountDisplay extends StatelessWidget {
  final String amount;
  final TransactionType type;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: type.actionBackgroundColor(context).withAlpha(0x1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: type.actionBackgroundColor(context),
          ),
        ),
      ),
    );
  }
}
