import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/list_utils.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/widgets/cubit_error_widget.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/account/presentation/widgets/account_card.dart';
import 'package:wisebuget/features/account/presentation/pages/account_form.dart';
import 'package:wisebuget/features/account/presentation/widgets/no_accounts.dart';
import 'package:wisebuget/features/account/presentation/widgets/total_balance_card.dart';
import 'package:wisebuget/features/settings/presentation/cubit/currency_rates_cubit.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab>
    with AutomaticKeepAliveClientMixin {
  bool _reordering = false;
  final TextEditingController _searchController = TextEditingController();
  late final CurrencyRatesCubit _ratesCubit;

  String get _searchQuery => _searchController.text.trim().toLowerCase();

  @override
  void initState() {
    super.initState();
    _ratesCubit = CurrencyRatesCubit(networkService: sl());
    _ratesCubit.loadRates(sl<LocalPreferences>().currency);
  }

  @override
  void dispose() {
    _ratesCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AccountCubit>()..loadAccounts()),
        BlocProvider.value(value: _ratesCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          centerTitle: false,
          title: Text(context.l10n.accounts, style: context.t.headlineMedium),
          actionsPadding: EdgeInsets.only(right: 16),
          actions: [
            ActionButton(
              icon: AppIcons.add,
              onTap: () => _showAddAccountDialog(context),
            ),
            SizedBox(width: 12),
            BlocBuilder<AccountCubit, AccountState>(
              builder: (context, state) {
                if (state.accounts.isEmpty) return const SizedBox.shrink();
                return ActionButton(
                  icon: _reordering ? AppIcons.check : AppIcons.chevronUpDown,
                  onTap: _toggleReorderMode,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<AccountCubit, AccountState>(
          builder: (context, state) {
            if (state.status == CubitStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CubitStatus.failure) {
              return CubitErrorWidget(
                message:
                    state.errorMessage ?? context.l10n.failedToLoadAccounts,
                onRetry: () => context.read<AccountCubit>().loadAccounts(),
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
              onAccountTap: (account) => _navigateToEdit(context, account),
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
    final reordered = applyReorder(accounts, oldIndex, newIndex);
    final cubit = context.read<AccountCubit>();
    for (int i = 0; i < reordered.length; i++) {
      final account = reordered[i];
      if (account.sortOrder != i) {
        cubit.editAccount(account.copyWith(sortOrder: i));
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    AccountEntity account,
  ) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: context.l10n.deleteAccount,
      message: context.l10n.areYouSureDeleteNamed(account.name),
      confirmText: context.l10n.delete,
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<AccountCubit>().removeAccount(account.uuid);
    }
  }

  Future<void> _showAddAccountDialog(BuildContext context) async {
    final result = await showAccountFormModal(context: context);
    if (result == true) {
      sl<AccountCubit>().loadAccounts();
    }
  }

  Future<void> _navigateToEdit(
    BuildContext context,
    AccountEntity account,
  ) async {
    await showAccountFormModal(context: context, account: account);
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Column(
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
                    onAddAccount: onAddAccount,
                    onAccountTap: onAccountTap,
                  ),
          ),
        ],
      ),
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
