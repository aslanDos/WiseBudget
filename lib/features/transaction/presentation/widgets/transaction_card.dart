import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity? category;
  final AccountEntity? account;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = AppPalette.fromValue(
      category?.colorValue,
      defaultColor: colorScheme.primary,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: context.c.secondary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _CategoryIcon(
                  icon: category?.icon ?? AppIcons.empty,
                  color: categoryColor,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: _TransactionDetails(
                    categoryName: category?.name ?? 'Unknown',
                    accountName: account?.name,
                    note: transaction.note,
                  ),
                ),
                const SizedBox(width: 12.0),
                _TransactionAmount(transaction: transaction),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _CategoryIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Icon(icon, color: color, size: 22.0),
    );
  }
}

class _TransactionDetails extends StatelessWidget {
  final String categoryName;
  final String? accountName;
  final String? note;

  const _TransactionDetails({
    required this.categoryName,
    required this.accountName,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          categoryName,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2.0),
        Text(
          _buildSecondaryText(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _buildSecondaryText() {
    final account = accountName ?? 'Unknown Account';
    final hasNote = note != null && note!.isNotEmpty;
    return hasNote ? '$account · $note' : account;
  }
}

class _TransactionAmount extends StatelessWidget {
  final TransactionEntity transaction;

  const _TransactionAmount({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (prefix, color) = _getAmountStyle(context);

    return Text(
      '$prefix${transaction.money.formatted}',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  (String, Color) _getAmountStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (transaction.type) {
      TransactionType.expense => ('-', AppColors.red),
      TransactionType.income => ('+', AppColors.green),
      TransactionType.transfer => ('', colorScheme.onSurfaceVariant),
    };
  }
}
