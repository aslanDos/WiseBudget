import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/app/pages/home/home_tab_body.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/account_chip.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;
  final String? selectedAccountUuid;
  final ValueChanged<String?> onAccountChanged;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const HomeTab({
    super.key,
    this.scrollController,
    required this.selectedAccountUuid,
    required this.onAccountChanged,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late final LocalPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _prefs = sl<LocalPreferences>();
    sl<TransactionCubit>().loadTransactions();
    sl<CategoryCubit>().loadCategories();
    sl<AccountCubit>().loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<TransactionCubit>()),
        BlocProvider.value(value: sl<CategoryCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          centerTitle: false,
          title: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, accountState) {
              final selected = accountState.accounts
                  .where(
                    (account) => account.uuid == widget.selectedAccountUuid,
                  )
                  .firstOrNull;

              return AccountChip(
                account: selected,
                accounts: accountState.accounts,
                allSelected: widget.selectedAccountUuid == null,
                onSelected: widget.onAccountChanged,
                onAllSelected: () => widget.onAccountChanged(null),
              );
            },
          ),
          actionsPadding: const EdgeInsets.only(right: 16),
          actions: [
            ActionButton(
              icon: AppIcons.settings,
              onTap: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
        body: HomeTabBody(
          selectedDate: widget.selectedDate,
          selectedAccountUuid: widget.selectedAccountUuid,
          onDateChanged: widget.onDateChanged,
          prefs: _prefs,
        ),
      ),
    );
  }
}
