import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class TotalBalanceCard extends StatelessWidget {
  final List<AccountEntity> accounts;

  const TotalBalanceCard({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group balances by currency
    final balancesByCurrency = <String, double>{};
    for (final account in accounts) {
      balancesByCurrency[account.currency] =
          (balancesByCurrency[account.currency] ?? 0) + account.balance;
    }

    // Get primary currency (first one or default)
    final primaryCurrency =
        accounts.isNotEmpty ? accounts.first.currency : 'USD';
    final totalBalance = balancesByCurrency[primaryCurrency] ?? 0;
    final totalMoney = Money(totalBalance, primaryCurrency);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            totalMoney.formatted,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (balancesByCurrency.length > 1) ...[
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: balancesByCurrency.entries
                  .where((e) => e.key != primaryCurrency)
                  .map((entry) {
                final money = Money(entry.value, entry.key);
                return Text(
                  money.formatted,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.7),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
