import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/pages/account_form.dart';
import 'package:wisebuget/features/account/presentation/widgets/account_transaction_tile.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';

class AccountDetailPage extends StatelessWidget {
  final AccountEntity account;

  const AccountDetailPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AccountCubit>()),
        BlocProvider.value(
          value: sl<TransactionCubit>()
            ..loadTransactionsByAccount(account.uuid),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(account.name),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => _navigateToEdit(context),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _showDeleteDialog(context),
            ),
          ],
        ),
        body: Column(
          children: [
            // Account header card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72.0,
                    height: 72.0,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Icon(
                      AppIcons.fromCode(account.iconCode),
                      size: 36.0,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    account.money.formatted,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: account.isNegative
                          ? colorScheme.error
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Current Balance',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transactions header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: theme.textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all transactions for this account
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),

            // Transactions list
            Expanded(
              child: BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, state) {
                  if (state.status == CubitStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            AppIcons.receipt,
                            size: 48.0,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'No transactions yet',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) => AccountTransactionTile(
                      transaction: state.transactions[index],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await showAccountFormModal(context: context, account: account);
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
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
