import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_occurrence.dart';
import 'package:wisebuget/features/transaction/domain/services/recurring_transaction_scheduler.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_state.dart';

Future<void> showRecurringTransactionsModal({
  required BuildContext context,
}) async {
  await showCupertinoModalBottomSheet<void>(
    context: context,
    expand: false,
    barrierColor: Colors.black54,
    builder: (context) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<RecurringTransactionCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()),
        BlocProvider.value(value: sl<CategoryCubit>()),
      ],
      child: const _RecurringTransactionsSheet(),
    ),
  );
}

class _RecurringTransactionsSheet extends StatefulWidget {
  const _RecurringTransactionsSheet();

  @override
  State<_RecurringTransactionsSheet> createState() =>
      _RecurringTransactionsSheetState();
}

class _RecurringTransactionsSheetState
    extends State<_RecurringTransactionsSheet> {
  @override
  void initState() {
    super.initState();
    sl<RecurringTransactionCubit>().loadRecurringTransactions();
    sl<AccountCubit>().loadAccounts();
    sl<CategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.78,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recurring transactions',
                        style: context.t.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(AppIcons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child:
                    BlocBuilder<
                      RecurringTransactionCubit,
                      RecurringTransactionState
                    >(
                      builder: (context, recurringState) {
                        if (recurringState.status == CubitStatus.loading &&
                            recurringState.transactions.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (recurringState.transactions.isEmpty) {
                          return _EmptyRecurringState();
                        }

                        return BlocBuilder<AccountCubit, AccountState>(
                          builder: (context, accountState) {
                            return BlocBuilder<CategoryCubit, CategoryState>(
                              builder: (context, categoryState) {
                                final accountsByUuid = {
                                  for (final item in accountState.accounts)
                                    item.uuid: item,
                                };
                                final categoriesByUuid = {
                                  for (final item in categoryState.categories)
                                    item.uuid: item,
                                };

                                return ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: recurringState.transactions.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final transaction =
                                        recurringState.transactions[index];
                                    return _RecurringTransactionCard(
                                      transaction: transaction,
                                      accountName:
                                          accountsByUuid[transaction
                                                  .accountUuid]
                                              ?.name,
                                      toAccountName:
                                          accountsByUuid[transaction
                                                  .toAccountUuid]
                                              ?.name,
                                      categoryName:
                                          categoriesByUuid[transaction
                                                  .categoryUuid]
                                              ?.name,
                                      categoryIcon:
                                          categoriesByUuid[transaction
                                                  .categoryUuid]
                                              ?.icon,
                                      onDelete: () => context
                                          .read<RecurringTransactionCubit>()
                                          .removeRecurringTransaction(
                                            transaction.uuid,
                                          ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecurringTransactionCard extends StatelessWidget {
  const _RecurringTransactionCard({
    required this.transaction,
    required this.accountName,
    required this.toAccountName,
    required this.categoryName,
    required this.categoryIcon,
    required this.onDelete,
  });

  final RecurringTransactionEntity transaction;
  final String? accountName;
  final String? toAccountName;
  final String? categoryName;
  final IconData? categoryIcon;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final nextOccurrence = _resolveNextOccurrence();
    final color = switch (transaction.type) {
      TransactionType.expense => AppColors.red,
      TransactionType.income => AppColors.green,
      TransactionType.transfer => AppColors.blue,
      TransactionType.adjustment => context.c.primary,
    };

    final title = transaction.type == TransactionType.transfer
        ? 'Transfer'
        : (categoryName ?? 'Recurring transaction');
    final subtitle = transaction.type == TransactionType.transfer
        ? '${accountName ?? '?'} -> ${toAccountName ?? '?'}'
        : (accountName ?? 'Unknown account');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(0x1F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.type == TransactionType.transfer
                      ? AppIcons.arrowUpDown
                      : (categoryIcon ?? Icons.repeat_rounded),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.t.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: context.t.bodySmall?.copyWith(
                        color: context.c.onSurface.withAlpha(0x80),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(AppIcons.trash, color: AppColors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: transaction.frequency.label),
              _InfoChip(label: 'Starts ${_formatDate(transaction.startDate)}'),
              if (nextOccurrence != null)
                _InfoChip(label: 'Next ${_formatDate(nextOccurrence.date)}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${transaction.type == TransactionType.expense
                ? '-'
                : transaction.type == TransactionType.income
                ? '+'
                : ''}${Money(transaction.amount, transaction.currency).formatted}',
            style: context.t.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  RecurringTransactionOccurrence? _resolveNextOccurrence() {
    final scheduler = const RecurringTransactionScheduler();
    final items = scheduler.buildOccurrencesInRange(
      [transaction],
      from: DateTime.now(),
      to: DateTime.now().add(const Duration(days: 180)),
      upcomingOnly: true,
    );
    return items.isEmpty ? null : items.first;
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${monthNames[date.month - 1]}';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.c.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.t.labelSmall?.copyWith(
          color: context.c.onSurface.withAlpha(0x80),
        ),
      ),
    );
  }
}

class _EmptyRecurringState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.repeat_rounded,
              size: 52,
              color: context.c.onSurface.withAlpha(0x33),
            ),
            const SizedBox(height: 12),
            Text('No recurring transactions yet', style: context.t.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Create one from the transaction form and it will appear here.',
              style: context.t.bodySmall?.copyWith(
                color: context.c.onSurface.withAlpha(0x70),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
