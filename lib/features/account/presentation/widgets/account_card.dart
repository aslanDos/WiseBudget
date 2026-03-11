import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';

class AccountCard extends StatelessWidget {
  final AccountEntity account;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AccountCard({
    super.key,
    required this.account,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Builder(
                builder: (context) {
                  final accountColor = AppPalette.fromValue(
                    account.colorValue,
                    defaultColor: colorScheme.secondary,
                  );
                  return Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: accountColor.withAlpha(0x66),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(
                      AppIcons.fromCode(account.iconCode),
                      size: 28.0,
                      color: accountColor,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      account.money.formatted,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: account.isNegative
                            ? colorScheme.error
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}
