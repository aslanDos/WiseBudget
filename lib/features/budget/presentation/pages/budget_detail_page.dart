import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_state.dart';
import 'package:wisebuget/features/budget/presentation/pages/budget_form_page.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_progress_bar.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';

class BudgetDetailPage extends StatelessWidget {
  final String budgetUuid;

  const BudgetDetailPage({super.key, required this.budgetUuid});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<BudgetCubit>()),
        BlocProvider.value(value: sl<TransactionCubit>()),
        BlocProvider.value(value: sl<CategoryCubit>()),
      ],
      child: BlocBuilder<BudgetCubit, BudgetState>(
        builder: (context, state) {
          final budgetProgress = state.budgets
              .where((b) => b.budget.uuid == budgetUuid)
              .firstOrNull;

          if (budgetProgress == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Budget not found')),
            );
          }

          return _BudgetDetailContent(progress: budgetProgress);
        },
      ),
    );
  }
}

class _BudgetDetailContent extends StatelessWidget {
  final BudgetProgress progress;

  const _BudgetDetailContent({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final budget = progress.budget;
    final budgetColor = AppPalette.fromValue(
      budget.colorValue,
      defaultColor: colors.primary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(budget.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editBudget(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progress Card
          _buildProgressCard(context, budgetColor),
          const SizedBox(height: 24),

          // Daily Breakdown
          _buildDailyBreakdown(context),
          const SizedBox(height: 24),

          // Transactions Section
          _buildTransactionsSection(context),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, Color budgetColor) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final budget = progress.budget;
    final isExceeded = progress.isExceeded;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Amount display
          Text(
            '${progress.spentMoney.formatted} of ${progress.limitMoney.formatted}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Circular progress
          BudgetCircularProgress(progress: progress, size: 160),

          const SizedBox(height: 24),

          // Remaining text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isExceeded
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 20,
                color: isExceeded ? colors.error : const Color(0xFF22C55E),
              ),
              const SizedBox(width: 8),
              Text(
                isExceeded
                    ? 'Over by ${progress.overByMoney.formatted}'
                    : '${progress.remainingMoney.formatted} remaining',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isExceeded ? colors.error : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            '${budget.daysRemaining} days left in ${budget.periodLabel}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final dailyBudget = progress.dailyBudget;
    final dailyAverage = progress.dailyAverage;
    final isOverPace = dailyAverage > dailyBudget && dailyBudget > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Breakdown',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Daily limit',
                  value: progress.dailyBudgetMoney.formatted,
                  icon: Icons.flag_outlined,
                  iconColor: colors.primary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Your average',
                  value: '\$${dailyAverage.toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  iconColor: isOverPace
                      ? colors.error
                      : const Color(0xFF22C55E),
                ),
              ),
            ],
          ),
          if (isOverPace) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorContainer.withAlpha(0x33),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 18, color: colors.error),
                  const SizedBox(width: 8),
                  Text(
                    'Spending ${((dailyAverage / dailyBudget - 1) * 100).toStringAsFixed(0)}% above daily pace',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final budget = progress.budget;

    return BlocBuilder<TransactionCubit, dynamic>(
      builder: (context, transactionState) {
        final transactions = sl<TransactionCubit>().state.transactions;
        final (startDate, endDate) = budget.currentPeriodRange;

        // Filter transactions matching budget criteria
        final matchingTransactions = transactions.where((t) {
          if (t.type != TransactionType.expense) return false;
          if (t.date.isBefore(startDate) || t.date.isAfter(endDate)) {
            return false;
          }
          if (budget.categoryUuids.isNotEmpty) {
            if (!budget.categoryUuids.contains(t.categoryUuid)) return false;
          }
          if (budget.accountUuids.isNotEmpty) {
            if (!budget.accountUuids.contains(t.accountUuid)) return false;
          }
          return true;
        }).toList();

        matchingTransactions.sort((a, b) => b.date.compareTo(a.date));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Transactions (${matchingTransactions.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            if (matchingTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: matchingTransactions.take(20).length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    indent: 56,
                    color: colors.outlineVariant.withAlpha(0x40),
                  ),
                  itemBuilder: (context, index) {
                    final transaction = matchingTransactions[index];
                    return _TransactionItem(transaction: transaction);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  void _editBudget(BuildContext context) async {
    final result = await showBudgetFormModal(
      context: context,
      budgetUuid: progress.budget.uuid,
    );
    if (result == true) {
      sl<BudgetCubit>().loadBudgets();
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionEntity transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Get category info
    final categoryState = sl<CategoryCubit>().state;
    final category = categoryState.categories
        .where((c) => c.uuid == transaction.categoryUuid)
        .firstOrNull;

    final categoryColor = category != null
        ? AppPalette.fromValue(
            category.colorValue,
            defaultColor: colors.primary,
          )
        : colors.primary;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: categoryColor.withAlpha(0x26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          category != null
              ? AppIcons.fromCode(category.iconCode)
              : Icons.category,
          size: 20,
          color: categoryColor,
        ),
      ),
      title: Text(
        category?.name ?? 'Unknown',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _formatDate(transaction.date),
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        '-${transaction.money.formatted}',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.error,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}';
  }
}
