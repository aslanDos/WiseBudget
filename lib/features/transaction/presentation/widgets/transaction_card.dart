import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/enums/transaction_type.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity? category;
  final AccountEntity? account;
  final AccountEntity? toAccount;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.category,
    this.account,
    this.toAccount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTransfer = transaction.isTransfer;
    final categoryColor = isTransfer
        ? AppColors.blue
        : AppPalette.fromValue(
            category?.colorValue,
            defaultColor: context.c.primary,
          );

    return Material(
      color: context.c.surfaceContainer,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ColoredIconBox(
                size: 24,
                icon: isTransfer
                    ? AppIcons.arrowUpDown
                    : (category?.icon ?? AppIcons.empty),
                color: categoryColor,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: isTransfer
                    ? _TransferDetails(
                        fromAccount: account,
                        toAccount: toAccount,
                      )
                    : _TransactionDetails(
                        categoryName: category?.name ?? 'Unknown',
                        accountName: account?.name,
                        note: transaction.note,
                      ),
              ),
              _TransactionAmount(transaction: transaction),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransferDetails extends StatelessWidget {
  final AccountEntity? fromAccount;
  final AccountEntity? toAccount;

  const _TransferDetails({
    required this.fromAccount,
    required this.toAccount,
  });

  @override
  Widget build(BuildContext context) {
    final fromName = fromAccount?.name ?? '?';
    final toName = toAccount?.name ?? '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Transfer',
          style: context.t.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Flexible(
              child: Text(
                fromName,
                style: context.t.bodySmall?.copyWith(color: context.c.onSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                AppIcons.chevronRight,
                size: 12,
                color: context.c.onSecondary,
              ),
            ),
            Flexible(
              child: Text(
                toName,
                style: context.t.bodySmall?.copyWith(color: context.c.onSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
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
          style: context.t.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2.0),
        Text(
          _buildSecondaryText(),
          style: context.t.bodySmall?.copyWith(color: context.c.onSecondary),
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
      style: context.t.bodyMedium?.copyWith(color: color),
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
