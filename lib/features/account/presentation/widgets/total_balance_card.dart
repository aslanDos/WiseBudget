import 'package:flutter/material.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class TotalBalanceCard extends StatelessWidget {
  final List<AccountEntity> accounts;
  final bool lowOpacity;

  const TotalBalanceCard({
    super.key,
    required this.accounts,
    required this.lowOpacity,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Group balances by currency
    final balancesByCurrency = <String, double>{};
    for (final account in accounts) {
      balancesByCurrency[account.currency] =
          (balancesByCurrency[account.currency] ?? 0) + account.balance;
    }

    // Get primary currency (first one or default)
    final primaryCurrency = accounts.isNotEmpty
        ? accounts.first.currency
        : 'USD';
    final totalBalance = balancesByCurrency[primaryCurrency] ?? 0;
    final totalMoney = Money(totalBalance, primaryCurrency);

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
              l10n.balance,
              style: context.t.titleMedium?.copyWith(
                color: context.c.onPrimary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              totalMoney.formatted,
              style: context.t.headlineMedium?.copyWith(
                color: context.c.onPrimary,
                fontWeight: FontWeight.w600,
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
                        style: context.t.bodyMedium?.copyWith(
                          color: context.c.onPrimary.withValues(alpha: 0.7),
                        ),
                      );
                    })
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
