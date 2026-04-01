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
        color: context.c.surfaceContainer,
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
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18.0),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          categoryName,
          style: context.t.headlineMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2.0),
        Text(
          _buildSecondaryText(),
          style: context.t.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _buildSecondaryText() {
    final account = accountName ?? 'Unknown Account';
    final hasNote = note != null && note!.isNotEmpty;
    return hasNote ? '$note' : account;
  }
}

class _TransactionAmount extends StatelessWidget {
  final TransactionEntity transaction;

  const _TransactionAmount({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final (prefix, color) = _getAmountStyle(context);

    return Text(
      '$prefix${transaction.money.formatted}',
      style: context.t.headlineMedium?.copyWith(color: color),
    );
  }

  (String, Color) _getAmountStyle(BuildContext context) {
    return switch (transaction.type) {
      TransactionType.expense => ('-', AppColors.red),
      TransactionType.income => ('+', AppColors.green),
      TransactionType.transfer => ('', AppColors.blue),
    };
  }
}
