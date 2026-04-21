import 'package:flutter/material.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';

class TotalBalanceCard extends StatelessWidget {
  final double totalInBase;
  final String baseCurrency;
  final bool lowOpacity;

  const TotalBalanceCard({
    super.key,
    required this.totalInBase,
    required this.baseCurrency,
    required this.lowOpacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: lowOpacity ? 0.5 : 1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.c.primary,
              context.c.primary.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.balance,
              style: context.t.titleMedium?.copyWith(
                color: context.c.onPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              Money(totalInBase, baseCurrency).formatted,
              style: context.t.headlineMedium?.copyWith(
                color: context.c.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
