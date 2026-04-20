import 'package:flutter/material.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';

class NoAccounts extends StatelessWidget {
  final VoidCallback? onAddAccount;

  const NoAccounts({super.key, this.onAddAccount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppIcons.wallet,
                size: 40.0,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              context.l10n.noAccountsYet,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              context.l10n.addFirstAccountDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24.0),
            FilledButton.icon(
              onPressed: onAddAccount,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addAccount),
            ),
          ],
        ),
      ),
    );
  }
}
