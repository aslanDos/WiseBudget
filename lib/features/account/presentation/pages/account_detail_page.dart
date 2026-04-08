import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/widgets/circle_icon_button.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
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
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
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
        body: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, txState) {
            if (txState.status == CubitStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final sorted = [...txState.transactions]
              ..sort((a, b) => b.date.compareTo(a.date));

            final groups = <String, List<TransactionEntity>>{};
            for (final t in sorted) {
              groups.putIfAbsent(DateFormatter.format(t.date), () => []).add(t);
            }

            return BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, catState) {
                return BlocBuilder<AccountCubit, AccountState>(
                  builder: (context, accState) {
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _AccountHeaderCard(account: account),
                          ),
                        ),
                        if (sorted.isEmpty)
                          SliverFillRemaining(child: _EmptyTransactions())
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            sliver: SliverList.list(
                              children: _buildGroups(
                                context,
                                groups,
                                catState,
                                accState,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildGroups(
    BuildContext context,
    Map<String, List<TransactionEntity>> groups,
    CategoryState catState,
    AccountState accState,
  ) {
    final widgets = <Widget>[];

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text('Recent Transactions', style: context.t.titleLarge),
      ),
    );

    bool firstGroup = true;
    for (final entry in groups.entries) {
      if (!firstGroup) widgets.add(const SizedBox(height: 16));
      firstGroup = false;

      widgets.add(_DateHeader(label: entry.key));
      widgets.add(const SizedBox(height: 8));

      for (final t in entry.value) {
        final category = catState.categories
            .where((c) => c.uuid == t.categoryUuid)
            .firstOrNull;
        final acc = accState.accounts
            .where((a) => a.uuid == t.accountUuid)
            .firstOrNull;
        final toAcc = accState.accounts
            .where((a) => a.uuid == t.toAccountUuid)
            .firstOrNull;

        widgets.add(
          TransactionCard(
            transaction: t,
            category: category,
            account: acc,
            toAccount: toAcc,
            onTap: () => showTransactionFormModal(
              context: context,
              initialType: t.type,
              transaction: t,
            ),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
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

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Delete Account',
      message:
          'Are you sure you want to delete "${account.name}"? '
          'This will also delete all associated transactions.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<AccountCubit>().removeAccount(account.uuid);
      context.pop(true);
    }
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

class _DateHeader extends StatelessWidget {
  final String label;

  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.t.bodySmall?.copyWith(color: context.c.onSecondary),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.receipt, size: 48, color: context.c.onSecondary),
          const SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: context.t.bodyMedium?.copyWith(color: context.c.onSecondary),
          ),
        ],
      ),
    );
  }
}
