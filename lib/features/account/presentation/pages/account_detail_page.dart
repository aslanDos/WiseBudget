import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/core/shared/widgets/form_section.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/account/presentation/pages/account_form.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_card.dart';

class AccountDetailPage extends StatelessWidget {
  final AccountEntity account;

  const AccountDetailPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AccountCubit>()..loadAccounts()),
        BlocProvider.value(value: sl<CategoryCubit>()..loadCategories()),
        BlocProvider.value(
          value: sl<TransactionCubit>()
            ..loadTransactionsByAccount(account.uuid),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          actionsPadding: const EdgeInsets.only(right: 16),

          actions: [
            CircleIconButton(
              icon: AppIcons.pencil,
              onTap: () => _navigateToEdit(context),
            ),
            const SizedBox(width: 12),
            CircleIconButton(
              icon: AppIcons.trash,
              iconColor: context.c.error,
              onTap: () => _showDeleteDialog(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _AccountHeaderCard(account: account),
              ),
              const SizedBox(height: 16),
              _RecentTransactionsSection(account: account),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await showAccountFormModal(
      context: context,
      account: account,
    );
    if (result == true && context.mounted) {
      context.pop(true);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${account.name}"? '
          'This will also delete all associated transactions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountCubit>().removeAccount(account.uuid);
              Navigator.pop(dialogContext);
              context.pop(true);
            },
            child: Text('Delete', style: TextStyle(color: context.c.error)),
          ),
        ],
      ),
    );
  }
}

class _AccountHeaderCard extends StatelessWidget {
  final AccountEntity account;

  const _AccountHeaderCard({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.c.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.c.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              AppIcons.fromCode(account.iconCode),
              size: 36,
              color: context.c.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            account.money.formatted,
            style: context.t.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: account.isNegative
                  ? context.c.error
                  : context.c.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current Balance',
            style: context.t.bodyMedium?.copyWith(
              color: context.c.onPrimaryContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsSection extends StatelessWidget {
  final AccountEntity account;

  const _RecentTransactionsSection({required this.account});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        if (transactionState.status == CubitStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final sorted = [...transactionState.transactions]
          ..sort((a, b) => b.date.compareTo(a.date));
        final recent = sorted.take(5).toList();

        return FormSection(
          title: 'Recent Transactions',
          actionLabel: transactionState.transactions.length > 5
              ? 'See All'
              : null,
          onAction: () {
            // TODO: Navigate to all transactions for this account
          },
          child: recent.isEmpty
              ? _EmptyTransactions()
              : BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, categoryState) {
                    return BlocBuilder<AccountCubit, AccountState>(
                      builder: (context, accountState) {
                        return _GroupedTransactionList(
                          transactions: recent,
                          categoryState: categoryState,
                          accountState: accountState,
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

class _GroupedTransactionList extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final CategoryState categoryState;
  final AccountState accountState;

  const _GroupedTransactionList({
    required this.transactions,
    required this.categoryState,
    required this.accountState,
  });

  @override
  Widget build(BuildContext context) {
    // Group transactions by date
    final groups = <String, List<TransactionEntity>>{};
    for (final t in transactions) {
      final label = DateFormatter.format(t.date);
      groups.putIfAbsent(label, () => []).add(t);
    }

    final widgets = <Widget>[];
    for (final entry in groups.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            entry.key,
            style: context.t.bodySmall?.copyWith(color: context.c.onSecondary),
          ),
        ),
      );

      for (int i = 0; i < entry.value.length; i++) {
        final transaction = entry.value[i];
        final category = categoryState.categories
            .where((c) => c.uuid == transaction.categoryUuid)
            .firstOrNull;
        final account = accountState.accounts
            .where((a) => a.uuid == transaction.accountUuid)
            .firstOrNull;
        final toAccount = accountState.accounts
            .where((a) => a.uuid == transaction.toAccountUuid)
            .firstOrNull;

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TransactionCard(
              transaction: transaction,
              category: category,
              account: account,
              toAccount: toAccount,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(AppIcons.receipt, size: 40, color: context.c.onSecondary),
            const SizedBox(height: 12),
            Text(
              'No transactions yet',
              style: context.t.bodyMedium?.copyWith(
                color: context.c.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
