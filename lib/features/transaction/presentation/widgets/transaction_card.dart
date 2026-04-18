import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';

class TransactionCard extends StatefulWidget {
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
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard> {
  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final isTransfer = transaction.isTransfer;
    final isAdjustment = transaction.isAdjustment;
    final categoryColor = isTransfer || isAdjustment
        ? context.c.primary
        : AppPalette.fromValue(
            widget.category?.colorValue,
            defaultColor: context.c.primary,
          );

    return Pressable(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.c.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ColoredIconBox(
              size: 24,
              icon: isTransfer
                  ? AppIcons.arrowUpDown
                  : isAdjustment
                  ? AppIcons.pen
                  : (widget.category?.icon ?? AppIcons.empty),
              color: categoryColor,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: isTransfer
                  ? _TransferDetails(
                      fromAccount: widget.account,
                      toAccount: widget.toAccount,
                    )
                  : isAdjustment
                  ? _AdjustmentDetails(account: widget.account)
                  : _TransactionDetails(
                      categoryName: widget.category?.name ?? 'Unknown',
                      accountName: widget.account?.name,
                      note: transaction.note,
                    ),
            ),
            _TransactionAmount(transaction: transaction),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentDetails extends StatelessWidget {
  final AccountEntity? account;

  const _AdjustmentDetails({required this.account});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Adjustment',
          style: context.t.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          account?.name ?? 'Unknown',
          style: context.t.bodySmall?.copyWith(color: context.c.onSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _TransferDetails extends StatelessWidget {
  final AccountEntity? fromAccount;
  final AccountEntity? toAccount;

  const _TransferDetails({required this.fromAccount, required this.toAccount});

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
                style: context.t.bodySmall?.copyWith(
                  color: context.c.onSecondary,
                ),
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
                style: context.t.bodySmall?.copyWith(
                  color: context.c.onSecondary,
                ),
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
      TransactionType.adjustment =>
        transaction.amount >= 0
            ? ('+', AppColors.green)
            : ('', AppColors.red), // money.formatted already includes '-'
    };
  }
}
