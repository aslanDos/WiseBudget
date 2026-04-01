import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/shared/widgets/frame.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/account/presentation/widgets/account_card.dart';
import 'package:wisebuget/features/account/presentation/widgets/add_account_card.dart';
import 'package:wisebuget/features/account/presentation/widgets/no_accounts.dart';
import 'package:wisebuget/features/account/presentation/widgets/total_balance_card.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab>
    with AutomaticKeepAliveClientMixin {
  bool _reordering = false;
  final TextEditingController _searchController = TextEditingController();

  String get _searchQuery => _searchController.text.trim().toLowerCase();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (_) => sl<AccountCubit>()..loadAccounts(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Accounts'),
          centerTitle: true,
          actions: [
            BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
                if (state.accounts.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  onPressed: _toggleReorderMode,
                  tooltip: _reordering ? 'Done' : 'Reorder',
                  icon: Icon(_reordering ? Icons.check : Icons.reorder),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.status == AccountStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == AccountStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48.0,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      state.errorMessage ?? 'Failed to load accounts',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16.0),
                    FilledButton(
                      onPressed: () =>
                          context.read<AccountCubit>().loadAccounts(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final accounts = state.accounts.toList()
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

            if (accounts.isEmpty) {
              return NoAccounts(
                onAddAccount: () => _showAddAccountDialog(context),
              );
            }

            return _AccountsContent(
              accounts: accounts,
              reordering: _reordering,
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: () => setState(() {}),
              onReorder: (oldIndex, newIndex) {
                _handleReorder(context, accounts, oldIndex, newIndex);
              },
              onDeleteAccount: (account) => _handleDelete(context, account),
              onAddAccount: () => _showAddAccountDialog(context),
              onAccountTap: (account) =>
                  _navigateToAccountDetail(context, account),
            );
          },
        ),
      ),
    );
  }

  void _toggleReorderMode() {
    setState(() {
      _reordering = !_reordering;
      if (_reordering) {
        _searchController.clear();
      }
    });
  }

  void _handleReorder(
    BuildContext context,
    List<AccountEntity> accounts,
    int oldIndex,
    int newIndex,
  ) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final cubit = context.read<AccountCubit>();
    final reorderedAccounts = List<AccountEntity>.from(accounts);
    final movedAccount = reorderedAccounts.removeAt(oldIndex);
    reorderedAccounts.insert(newIndex, movedAccount);

    for (int i = 0; i < reorderedAccounts.length; i++) {
      final account = reorderedAccounts[i];
      if (account.sortOrder != i) {
        cubit.editAccount(account.copyWith(sortOrder: i));
      }
    }
  }

  void _handleDelete(BuildContext context, AccountEntity account) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AccountCubit>().removeAccount(account.uuid);
              Navigator.pop(dialogContext);
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

  Future<void> _showAddAccountDialog(BuildContext context) async {
    final result = await context.push(AppRoutes.accountForm);
    if (result == true && context.mounted) {
      context.read<AccountCubit>().loadAccounts();
    }
  }

  Future<void> _navigateToAccountDetail(
    BuildContext context,
    AccountEntity account,
  ) async {
    final result = await context.push(AppRoutes.accountDetail, extra: account);
    if (result == true && context.mounted) {
      context.read<AccountCubit>().loadAccounts();
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _AccountsContent extends StatelessWidget {
  final List<AccountEntity> accounts;
  final bool reordering;
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onSearchChanged;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(AccountEntity account) onDeleteAccount;
  final VoidCallback onAddAccount;
  final void Function(AccountEntity account) onAccountTap;

  const _AccountsContent({
    required this.accounts,
    required this.reordering,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onReorder,
    required this.onDeleteAccount,
    required this.onAddAccount,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSearchBar = accounts.length > 4;
    final filteredAccounts = searchQuery.isEmpty
        ? accounts
        : accounts
              .where((a) => a.name.toLowerCase().contains(searchQuery))
              .toList();

    return Column(
      children: [
        Frame(
          child: Column(
            children: [
              TotalBalanceCard(accounts: accounts),
              if (hasSearchBar && !reordering) ...[
                const SizedBox(height: 16.0),
                TextField(
                  controller: searchController,
                  onChanged: (_) => onSearchChanged(),
                  decoration: InputDecoration(
                    hintText: 'Search accounts',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              onSearchChanged();
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: reordering
              ? _ReorderableAccountList(
                  accounts: filteredAccounts,
                  onReorder: onReorder,
                )
              : _AccountList(
                  accounts: filteredAccounts,
                  onDeleteAccount: onDeleteAccount,
                  onAddAccount: onAddAccount,
                  onAccountTap: onAccountTap,
                ),
        ),
      ],
    );
  }
}

class _AccountList extends StatelessWidget {
  final List<AccountEntity> accounts;
  final void Function(AccountEntity account) onDeleteAccount;
  final VoidCallback onAddAccount;
  final void Function(AccountEntity account) onAccountTap;

  const _AccountList({
    required this.accounts,
    required this.onDeleteAccount,
    required this.onAddAccount,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: accounts.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == accounts.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 96.0),
            child: AddAccountCard(onTap: onAddAccount),
          );
        }

        final account = accounts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AccountCard(
            account: account,
            onTap: () => onAccountTap(account),
            onLongPress: () => onDeleteAccount(account),
          ),
        );
      },
    );
  }
}

class _ReorderableAccountList extends StatelessWidget {
  final List<AccountEntity> accounts;
  final void Function(int oldIndex, int newIndex) onReorder;

  const _ReorderableAccountList({
    required this.accounts,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ).copyWith(bottom: 96.0),
      itemCount: accounts.length,
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final elevation = Tween<double>(
              begin: 0,
              end: 4,
            ).animate(animation);
            return Material(
              elevation: elevation.value,
              borderRadius: BorderRadius.circular(16.0),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final account = accounts[index];
        return Padding(
          key: ValueKey(account.uuid),
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AccountCard(account: account),
        );
      },
    );
  }
}
