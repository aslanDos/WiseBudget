import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/prefs/local_prefs.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/core/shared/widgets/calendar.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_occurrence.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/services/recurring_transaction_scheduler.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_card.dart';

class HomeTabBody extends StatelessWidget {
  static const _recurringHorizonDays = 180;

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
        final recurringState = context.watch<RecurringTransactionCubit>().state;
        final recurringFiltered = _filterRecurringByAccount(
          recurringState.transactions,
          selectedAccountUuid,
        );
        final recurringOccurrences = const RecurringTransactionScheduler()
            .buildOccurrencesInRange(
              recurringFiltered,
              from: DateTime.now(),
              to: DateTime.now().add(
                const Duration(days: _recurringHorizonDays),
              ),
              upcomingOnly: true,
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
                  recurringTransactions: recurringFiltered,
                  recurringOccurrences: recurringOccurrences,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<RecurringTransactionEntity> _filterRecurringByAccount(
    List<RecurringTransactionEntity> transactions,
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
  final List<RecurringTransactionEntity> recurringTransactions;
  final List<RecurringTransactionOccurrence> recurringOccurrences;

  const _TransactionsList({
    required this.selectedDate,
    required this.transactions,
    required this.recurringTransactions,
    required this.recurringOccurrences,
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

        final categoriesByUuid = {
          for (final category in categories) category.uuid: category,
        };
        final accountsByUuid = {
          for (final account in accounts) account.uuid: account,
        };
        final items = _buildItems(
          transactions: dateFiltered,
          recurringTransactions: recurringTransactions,
          categoriesByUuid: categoriesByUuid,
          accountsByUuid: accountsByUuid,
        );
        final pendingOccurrences = _buildPendingOccurrences(
          actualTransactions: dateFiltered,
          categoriesByUuid: categoriesByUuid,
          accountsByUuid: accountsByUuid,
        );

        if (items.isEmpty && pendingOccurrences.isEmpty) {
          return _EmptyState();
        }

        return ListView.separated(
          key: const PageStorageKey('home_transactions_list'),
          padding: const EdgeInsets.symmetric(vertical: 16),
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemCount: items.length + pendingOccurrences.length,
          itemBuilder: (context, index) {
            if (index < pendingOccurrences.length) {
              final occurrence = pendingOccurrences[index];
              return _RecurringOccurrenceCard(
                occurrence: occurrence,
                onTap: () => _openRecurringOccurrenceForm(context, occurrence),
              );
            }

            final item = items[index - pendingOccurrences.length];

            return TransactionCard(
              transaction: item.transaction,
              category: item.category,
              account: item.account,
              toAccount: item.toAccount,
              isRecurring: item.recurringTemplate != null,
              onTap: () => _openTransactionForm(
                context,
                item.transaction,
                recurringTemplate: item.recurringTemplate,
              ),
              onEdit: () => _openTransactionForm(
                context,
                item.transaction,
                recurringTemplate: item.recurringTemplate,
              ),
              onDelete: () => _handleDeleteTransaction(context, item),
            );
          },
        );
      },
    );
  }

  List<_TransactionListItem> _buildItems({
    required List<TransactionEntity> transactions,
    required List<RecurringTransactionEntity> recurringTransactions,
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
            recurringTemplate: _findRecurringTemplate(
              transaction,
              recurringTransactions,
            ),
          ),
        )
        .toList();
  }

  RecurringTransactionEntity? _findRecurringTemplate(
    TransactionEntity transaction,
    List<RecurringTransactionEntity> recurringTransactions,
  ) {
    if (transaction.isAdjustment) return null;
    final linkedTemplateUuid = transaction.recurringTemplateUuid;
    if (linkedTemplateUuid != null) {
      return recurringTransactions
          .where((template) => template.uuid == linkedTemplateUuid)
          .firstOrNull;
    }

    final transactionDay = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );

    for (final template in recurringTransactions) {
      if (!_matchesRecurringTemplate(transaction, template)) continue;
      if (const RecurringTransactionScheduler().occursOnDate(
        template,
        transactionDay,
      )) {
        return template;
      }
    }

    return null;
  }

  bool _matchesRecurringTemplate(
    TransactionEntity transaction,
    RecurringTransactionEntity template,
  ) {
    if (transaction.recurringTemplateUuid == template.uuid) return true;

    return transaction.type == template.type &&
        transaction.accountUuid == template.accountUuid &&
        transaction.toAccountUuid == template.toAccountUuid &&
        transaction.categoryUuid == template.categoryUuid &&
        transaction.amount == template.amount &&
        transaction.currency == template.currency &&
        (transaction.note ?? '') == (template.note ?? '');
  }

  List<_RecurringOccurrenceListItem> _buildPendingOccurrences({
    required List<TransactionEntity> actualTransactions,
    required Map<String, CategoryEntity> categoriesByUuid,
    required Map<String, AccountEntity> accountsByUuid,
  }) {
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (selectedDay.isBefore(todayOnly)) return const [];

    final sameDayOccurrences = recurringOccurrences
        .where((item) => item.date == selectedDay)
        .where((item) => !_hasActualMatch(item, actualTransactions))
        .toList();

    return sameDayOccurrences
        .map(
          (item) => _RecurringOccurrenceListItem(
            occurrence: item,
            category: categoriesByUuid[item.template.categoryUuid],
            account: accountsByUuid[item.template.accountUuid],
            toAccount: accountsByUuid[item.template.toAccountUuid],
          ),
        )
        .toList();
  }

  bool _hasActualMatch(
    RecurringTransactionOccurrence occurrence,
    List<TransactionEntity> actualTransactions,
  ) {
    final template = occurrence.template;
    return actualTransactions.any(
      (transaction) => _matchesRecurringTemplate(transaction, template),
    );
  }

  Future<void> _handleDeleteTransaction(
    BuildContext context,
    _TransactionListItem item,
  ) async {
    final template = item.recurringTemplate;
    final transactionCubit = context.read<TransactionCubit>();
    final recurringCubit = context.read<RecurringTransactionCubit>();

    if (template == null) {
      transactionCubit.removeTransaction(item.transaction.uuid);
      return;
    }

    final action = await showAppActionDialog<_RecurringDeleteAction>(
      context: context,
      title: context.l10n.repeatingTransaction,
      message: context.l10n.repeatingTransactionDeleteMessage,
      actions: [
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.cancel,
          value: null,
        ),
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.stopRepeat,
          value: _RecurringDeleteAction.stopRepeat,
        ),
        AppDialogAction<_RecurringDeleteAction>(
          text: context.l10n.deleteSeries,
          value: _RecurringDeleteAction.deleteSeries,
          isDestructive: true,
        ),
      ],
    );

    switch (action) {
      case _RecurringDeleteAction.stopRepeat:
        recurringCubit.updateRecurringTransaction(
          template.copyWith(isActive: false),
        );
      case _RecurringDeleteAction.deleteSeries:
        recurringCubit.removeRecurringTransaction(template.uuid);
        final linkedTransactions = transactionCubit.state.transactions
            .where(
              (transaction) =>
                  transaction.recurringTemplateUuid == template.uuid ||
                  transaction.uuid == item.transaction.uuid,
            )
            .toList();
        for (final transaction in linkedTransactions) {
          transactionCubit.removeTransaction(transaction.uuid);
        }
      case null:
        break;
    }
  }

  void _openRecurringOccurrenceForm(
    BuildContext context,
    _RecurringOccurrenceListItem item,
  ) {
    final occurrence = item.occurrence;
    showTransactionFormModal(
      context: context,
      initialType: occurrence.template.type,
      transaction: _transactionFromOccurrence(occurrence),
      isDraft: true,
      recurringTemplate: occurrence.template,
    );
  }

  TransactionEntity _transactionFromOccurrence(
    RecurringTransactionOccurrence occurrence,
  ) {
    final template = occurrence.template;
    return TransactionEntity(
      uuid: template.uuid,
      amount: template.amount,
      currency: template.currency,
      type: template.type,
      categoryUuid: template.categoryUuid,
      accountUuid: template.accountUuid,
      toAccountUuid: template.toAccountUuid,
      note: template.note,
      date: occurrence.date,
      createdDate: DateTime.now(),
      recurringTemplateUuid: template.uuid,
    );
  }

  void _openTransactionForm(
    BuildContext context,
    TransactionEntity transaction, {
    RecurringTransactionEntity? recurringTemplate,
  }) {
    showTransactionFormModal(
      context: context,
      initialType: transaction.type,
      transaction: transaction,
      recurringTemplate: recurringTemplate,
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.banknote, size: 64.0, color: context.c.onSecondary),
          const SizedBox(height: 16.0),
          Text(
            'No transactions for\nthe selected day',
            style: context.t.titleMedium?.copyWith(
              color: context.c.onSecondary,
            ),
            textAlign: TextAlign.center,
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
  final RecurringTransactionEntity? recurringTemplate;

  const _TransactionListItem({
    required this.transaction,
    required this.category,
    required this.account,
    required this.toAccount,
    required this.recurringTemplate,
  });
}

enum _RecurringDeleteAction { stopRepeat, deleteSeries }

class _RecurringOccurrenceListItem {
  final RecurringTransactionOccurrence occurrence;
  final CategoryEntity? category;
  final AccountEntity? account;
  final AccountEntity? toAccount;

  const _RecurringOccurrenceListItem({
    required this.occurrence,
    required this.category,
    required this.account,
    required this.toAccount,
  });
}

class _RecurringOccurrenceCard extends StatelessWidget {
  final _RecurringOccurrenceListItem occurrence;
  final VoidCallback onTap;

  const _RecurringOccurrenceCard({
    required this.occurrence,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final template = occurrence.occurrence.template;
    return TransactionCard(
      transaction: TransactionEntity(
        uuid: template.uuid,
        amount: template.amount,
        currency: template.currency,
        type: template.type,
        categoryUuid: template.categoryUuid,
        accountUuid: template.accountUuid,
        toAccountUuid: template.toAccountUuid,
        note: template.note,
        date: occurrence.occurrence.date,
        createdDate: template.createdDate,
      ),
      category: occurrence.category,
      account: occurrence.account,
      toAccount: occurrence.toAccount,
      isRecurring: true,
      onTap: onTap,
    );
  }
}
