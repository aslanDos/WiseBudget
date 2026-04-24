import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/app/pages/account/account_tab_body.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/list_utils.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/account/presentation/pages/account_form.dart';
import 'package:wisebuget/features/settings/presentation/cubit/currency_rates_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';

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
        BlocProvider.value(value: sl<TransactionCubit>()),
      ],
      child: BlocListener<TransactionCubit, TransactionState>(
        listenWhen: (previous, current) =>
            previous.status == CubitStatus.loading &&
            current.status == CubitStatus.success,
        listener: (context, state) {
          context.read<AccountCubit>().loadAccounts();
        },
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            centerTitle: false,
            title: Text(context.l10n.accounts, style: context.t.headlineMedium),
            actionsPadding: const EdgeInsets.only(right: 16),
            actions: [
              ActionButton(
                icon: AppIcons.add,
                onTap: () => _showAddAccountDialog(context),
              ),
              const SizedBox(width: 12),
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
          body: AccountTabBody(
            reordering: _reordering,
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: () => setState(() {}),
            onReorder: (oldIndex, newIndex) {
              final accounts = context.read<AccountCubit>().state.accounts;
              _handleReorder(context, accounts, oldIndex, newIndex);
            },
            onDeleteAccount: (account) => _handleDelete(context, account),
            onAddAccount: () => _showAddAccountDialog(context),
            onAccountTap: (account) => _navigateToEdit(context, account),
          ),
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
