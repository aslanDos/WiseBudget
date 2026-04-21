import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/shared/widgets/account_chip.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/core/shared/widgets/calendar/calendar.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_card.dart';

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
  DateTime get _selectedDate => widget.selectedDate;
  String? get _selectedAccountUuid => widget.selectedAccountUuid;

  @override
  void initState() {
    super.initState();
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
                  .where((a) => a.uuid == _selectedAccountUuid)
                  .firstOrNull;
              return AccountChip(
                account: selected,
                accounts: accountState.accounts,
                allSelected: _selectedAccountUuid == null,
                onSelected: widget.onAccountChanged,
                onAllSelected: () => widget.onAccountChanged(null),
              );
            },
          ),
          actionsPadding: EdgeInsets.only(right: 16),
          actions: [
            ActionButton(
              icon: AppIcons.settings,
              onTap: () => context.push(AppRoutes.settings),
            ),
          ],
        ),
        body: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, transactionState) {
            // Filter by account here — this builder re-runs on both bloc
            // state changes AND parent setState (selectedAccountUuid change).
            final accountFiltered = _filterByAccount(
              transactionState.transactions,
            );
            final datesWithTransactions = _extractDatesWithTransactions(
              accountFiltered,
            );

            // Totals for the selected date in base currency
            final dayTransactions = accountFiltered.where((t) {
              return t.date.year == _selectedDate.year &&
                  t.date.month == _selectedDate.month &&
                  t.date.day == _selectedDate.day;
            });
            final baseCurrency = sl<LocalPreferences>().currency;
            double incomeTotal = 0;
            double expenseTotal = 0;
            for (final t in dayTransactions) {
              if (t.isIncome) incomeTotal += t.amountInBase;
              if (t.isExpense) expenseTotal += t.amountInBase;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Calendar(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) => widget.onDateChanged(date),
                    datesWithTransactions: datesWithTransactions,
                  ),

                  const SizedBox(height: 24),

                  _Header(
                    selectedDate: _selectedDate,
                    income: incomeTotal > 0
                        ? Money(incomeTotal, baseCurrency)
                        : null,
                    expense: expenseTotal > 0
                        ? Money(expenseTotal, baseCurrency)
                        : null,
                  ),

                  Expanded(
                    child: _TransactionsList(
                      selectedDate: _selectedDate,
                      transactions: accountFiltered,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<TransactionEntity> _filterByAccount(List<TransactionEntity> all) {
    if (_selectedAccountUuid == null) return all;
    return all
        .where(
          (t) =>
              t.accountUuid == _selectedAccountUuid ||
              t.toAccountUuid == _selectedAccountUuid,
        )
        .toList();
  }

  Set<DateTime> _extractDatesWithTransactions(
    List<TransactionEntity> transactions,
  ) {
    return transactions
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toSet();
  }
}

class _TransactionsList extends StatelessWidget {
  final DateTime selectedDate;
  final List<TransactionEntity> transactions;

  const _TransactionsList({
    required this.selectedDate,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        if (transactionState.status == CubitStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (transactionState.status == CubitStatus.failure) {
          return Center(
            child: Text(
              transactionState.errorMessage ?? 'Failed to load transactions',
            ),
          );
        }

        // Account filtering is done upstream; only filter by date here.
        final dateFiltered = transactions.where((t) {
          return t.date.year == selectedDate.year &&
              t.date.month == selectedDate.month &&
              t.date.day == selectedDate.day;
        }).toList();

        if (dateFiltered.isEmpty) {
          return _EmptyState(selectedDate: selectedDate);
        }

        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return BlocBuilder<AccountCubit, AccountState>(
              builder: (context, accountState) {
                return ListView.separated(
                  key: const PageStorageKey('home_transactions_list'),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: dateFiltered.length,
                  itemBuilder: (context, index) {
                    final transaction = dateFiltered[index];
                    // Find category
                    final category = categoryState.categories
                        .where((c) => c.uuid == transaction.categoryUuid)
                        .firstOrNull;

                    // Find account
                    final account = accountState.accounts
                        .where((a) => a.uuid == transaction.accountUuid)
                        .firstOrNull;
                    final toAccount = accountState.accounts
                        .where((a) => a.uuid == transaction.toAccountUuid)
                        .firstOrNull;

                    return TransactionCard(
                      transaction: transaction,
                      category: category,
                      account: account,
                      toAccount: toAccount,
                      onTap: () {
                        showTransactionFormModal(
                          context: context,
                          initialType: transaction.type,
                          transaction: transaction,
                        );
                      },
                      onEdit: () => showTransactionFormModal(
                        context: context,
                        initialType: transaction.type,
                        transaction: transaction,
                      ),
                      onDelete: () => sl<TransactionCubit>()
                          .removeTransaction(transaction.uuid),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final DateTime selectedDate;
  final Money? income;
  final Money? expense;

  const _Header({required this.selectedDate, this.income, this.expense});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(DateFormatter.format(selectedDate), style: context.t.titleMedium),
        const Spacer(),
        if (expense != null)
          _TotalChip(prefix: '-', money: expense!, color: AppColors.red),
        if (income != null && expense != null) const SizedBox(width: 8),
        if (income != null)
          _TotalChip(prefix: '+', money: income!, color: AppColors.green),
      ],
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String prefix;
  final Money money;
  final Color color;

  const _TotalChip({
    required this.prefix,
    required this.money,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$prefix ${money.formattedNoMarker}',
        style: context.t.titleSmall?.copyWith(color: context.c.onSecondary),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final DateTime selectedDate;

  const _EmptyState({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.0,
            color: context.c.onSecondary,
          ),
          const SizedBox(height: 16.0),
          Text(
            'No transactions',
            style: context.t.titleMedium?.copyWith(
              color: context.c.onSecondary,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'for ${DateFormatter.format(selectedDate)}',
            style: context.t.bodyMedium?.copyWith(color: context.c.onSecondary),
          ),
        ],
      ),
    );
  }
}
