import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/core/shared/widgets/calendar/calendar.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_card.dart';

class HomeTabBody extends StatelessWidget {
  final DateTime selectedDate;
  final String? selectedAccountUuid;
  final ValueChanged<DateTime> onDateChanged;
  final LocalPreferences prefs;

  const HomeTabBody({
    super.key,
    required this.selectedDate,
    required this.selectedAccountUuid,
    required this.onDateChanged,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        final accountFiltered = _filterByAccount(
          transactionState.transactions,
          selectedAccountUuid,
        );
        final datesWithTransactions = _extractDatesWithTransactions(
          accountFiltered,
        );
        final summary = _buildDailySummary(
          transactions: accountFiltered,
          selectedDate: selectedDate,
          baseCurrency: prefs.currency,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Calendar(
                selectedDate: selectedDate,
                onDateSelected: onDateChanged,
                datesWithTransactions: datesWithTransactions,
              ),
              const SizedBox(height: 24),
              _Header(
                selectedDate: selectedDate,
                income: summary.income,
                expense: summary.expense,
              ),
              Expanded(
                child: _TransactionsList(
                  selectedDate: selectedDate,
                  transactions: accountFiltered,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<TransactionEntity> _filterByAccount(
    List<TransactionEntity> transactions,
    String? selectedAccountUuid,
  ) {
    if (selectedAccountUuid == null) return transactions;
    return transactions
        .where(
          (transaction) =>
              transaction.accountUuid == selectedAccountUuid ||
              transaction.toAccountUuid == selectedAccountUuid,
        )
        .toList();
  }

  Set<DateTime> _extractDatesWithTransactions(
    List<TransactionEntity> transactions,
  ) {
    return transactions
        .map(
          (transaction) => DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          ),
        )
        .toSet();
  }

  _DailySummary _buildDailySummary({
    required List<TransactionEntity> transactions,
    required DateTime selectedDate,
    required String baseCurrency,
  }) {
    double incomeTotal = 0;
    double expenseTotal = 0;

    for (final transaction in transactions) {
      final isSelectedDay =
          transaction.date.year == selectedDate.year &&
          transaction.date.month == selectedDate.month &&
          transaction.date.day == selectedDate.day;
      if (!isSelectedDay) continue;

      if (transaction.isIncome) incomeTotal += transaction.amountInBase;
      if (transaction.isExpense) expenseTotal += transaction.amountInBase;
    }

    return _DailySummary(
      income: incomeTotal > 0 ? Money(incomeTotal, baseCurrency) : null,
      expense: expenseTotal > 0 ? Money(expenseTotal, baseCurrency) : null,
    );
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
    final categories = context.select(
      (CategoryCubit cubit) => cubit.state.categories,
    );
    final accounts = context.select(
      (AccountCubit cubit) => cubit.state.accounts,
    );

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

        final dateFiltered = transactions.where((transaction) {
          return transaction.date.year == selectedDate.year &&
              transaction.date.month == selectedDate.month &&
              transaction.date.day == selectedDate.day;
        }).toList();

        if (dateFiltered.isEmpty) {
          return _EmptyState(selectedDate: selectedDate);
        }

        final categoriesByUuid = {
          for (final category in categories) category.uuid: category,
        };
        final accountsByUuid = {
          for (final account in accounts) account.uuid: account,
        };
        final items = _buildItems(
          transactions: dateFiltered,
          categoriesByUuid: categoriesByUuid,
          accountsByUuid: accountsByUuid,
        );

        return ListView.separated(
          key: const PageStorageKey('home_transactions_list'),
          padding: const EdgeInsets.symmetric(vertical: 16),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return TransactionCard(
              transaction: item.transaction,
              category: item.category,
              account: item.account,
              toAccount: item.toAccount,
              onTap: () => _openTransactionForm(context, item.transaction),
              onEdit: () => _openTransactionForm(context, item.transaction),
              onDelete: () => context
                  .read<TransactionCubit>()
                  .removeTransaction(item.transaction.uuid),
            );
          },
        );
      },
    );
  }

  List<_TransactionListItem> _buildItems({
    required List<TransactionEntity> transactions,
    required Map<String, CategoryEntity> categoriesByUuid,
    required Map<String, AccountEntity> accountsByUuid,
  }) {
    return transactions
        .map(
          (transaction) => _TransactionListItem(
            transaction: transaction,
            category: categoriesByUuid[transaction.categoryUuid],
            account: accountsByUuid[transaction.accountUuid],
            toAccount: accountsByUuid[transaction.toAccountUuid],
          ),
        )
        .toList();
  }

  void _openTransactionForm(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    showTransactionFormModal(
      context: context,
      initialType: transaction.type,
      transaction: transaction,
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

class _DailySummary {
  final Money? income;
  final Money? expense;

  const _DailySummary({required this.income, required this.expense});
}

class _TransactionListItem {
  final TransactionEntity transaction;
  final CategoryEntity? category;
  final AccountEntity? account;
  final AccountEntity? toAccount;

  const _TransactionListItem({
    required this.transaction,
    required this.category,
    required this.account,
    required this.toAccount,
  });
}
