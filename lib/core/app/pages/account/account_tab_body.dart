import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/widgets/cubit_error_widget.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/account/presentation/widgets/account_card.dart';
import 'package:wisebuget/features/account/presentation/widgets/no_accounts.dart';
import 'package:wisebuget/features/account/presentation/widgets/total_balance_card.dart';
import 'package:wisebuget/features/settings/presentation/cubit/currency_rates_cubit.dart';

class AccountTabBody extends StatelessWidget {
  final bool reordering;
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onSearchChanged;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(AccountEntity account) onDeleteAccount;
  final VoidCallback onAddAccount;
  final void Function(AccountEntity account) onAccountTap;

  const AccountTabBody({
    super.key,
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
    return BlocBuilder<AccountCubit, AccountState>(
      builder: (context, state) {
        if (state.status == CubitStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == CubitStatus.failure) {
          return CubitErrorWidget(
            message: state.errorMessage ?? context.l10n.failedToLoadAccounts,
            onRetry: () => context.read<AccountCubit>().loadAccounts(),
          );
        }

        final accounts = state.accounts.toList()
          ..sort((left, right) => left.sortOrder.compareTo(right.sortOrder));

        if (accounts.isEmpty) {
          return NoAccounts(onAddAccount: onAddAccount);
        }

        return _AccountsContent(
          accounts: accounts,
          reordering: reordering,
          searchController: searchController,
          searchQuery: searchQuery,
          onSearchChanged: onSearchChanged,
          onReorder: onReorder,
          onDeleteAccount: onDeleteAccount,
          onAccountTap: onAccountTap,
        );
      },
    );
  }
}

class _AccountsContent extends StatelessWidget {
  final List<AccountEntity> accounts;
  final bool reordering;
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onSearchChanged;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(AccountEntity account) onDeleteAccount;
  final void Function(AccountEntity account) onAccountTap;

  const _AccountsContent({
    required this.accounts,
    required this.reordering,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onReorder,
    required this.onDeleteAccount,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSearchBar = accounts.length > 4;
    final filteredAccounts = searchQuery.isEmpty
        ? accounts
        : accounts
              .where(
                (account) => account.name.toLowerCase().contains(searchQuery),
              )
              .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AccountTabHeader(
            accounts: accounts,
            reordering: reordering,
            hasSearchBar: hasSearchBar,
            searchController: searchController,
            searchQuery: searchQuery,
            onSearchChanged: onSearchChanged,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: reordering
                ? _ReorderableAccountList(
                    accounts: filteredAccounts,
                    onReorder: onReorder,
                  )
                : _AccountList(
                    accounts: filteredAccounts,
                    onDeleteAccount: onDeleteAccount,
                    onAccountTap: onAccountTap,
                  ),
          ),
        ],
      ),
    );
  }
}

class _AccountTabHeader extends StatelessWidget {
  final List<AccountEntity> accounts;
  final bool reordering;
  final bool hasSearchBar;
  final TextEditingController searchController;
  final String searchQuery;
  final VoidCallback onSearchChanged;

  const _AccountTabHeader({
    required this.accounts,
    required this.reordering,
    required this.hasSearchBar,
    required this.searchController,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<CurrencyRatesCubit, CurrencyRatesState>(
          builder: (context, ratesState) {
            final baseCurrency = ratesState.baseCurrency.isNotEmpty
                ? ratesState.baseCurrency
                : sl<LocalPreferences>().currency;
            double totalInBase = 0;
            for (final account in accounts) {
              final rate =
                  ratesState.rateFor(account.currency) ??
                  (account.currency == baseCurrency ? 1.0 : 0.0);
              totalInBase += account.balance * rate;
            }
            return TotalBalanceCard(
              totalInBase: totalInBase,
              baseCurrency: baseCurrency,
              lowOpacity: reordering,
            );
          },
        ),
        if (hasSearchBar && !reordering) ...[
          const SizedBox(height: 16.0),
          TextField(
            controller: searchController,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: context.l10n.searchAccounts,
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
    );
  }
}

class _AccountList extends StatelessWidget {
  final List<AccountEntity> accounts;
  final void Function(AccountEntity account) onDeleteAccount;
  final void Function(AccountEntity account) onAccountTap;

  const _AccountList({
    required this.accounts,
    required this.onDeleteAccount,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: accounts.length,
      itemBuilder: (context, index) {
        final account = accounts[index];

        return Padding(
          padding: EdgeInsets.only(
            bottom: index == accounts.length - 1 ? 0 : 12,
          ),
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
      padding: EdgeInsets.zero,
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
              borderRadius: BorderRadius.circular(12.0),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final account = accounts[index];

        return Container(
          key: ValueKey(account.uuid),
          margin: EdgeInsets.only(
            bottom: index == accounts.length - 1 ? 0 : 12,
          ),
          child: AccountCard(account: account),
        );
      },
    );
  }
}
