import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/shared/widgets/dialog.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/domain/entity/account_entity.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/recurring_transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/domain/recurrence_frequency.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/recurring_transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_card.dart';

Future<void> showTransactionSearchModal({required BuildContext context}) {
  return showModal<void>(
    context: context,
    expand: true,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<TransactionCubit>()),
        BlocProvider.value(value: sl<RecurringTransactionCubit>()),
        BlocProvider.value(value: sl<CategoryCubit>()),
        BlocProvider.value(value: sl<AccountCubit>()),
      ],
      child: const TransactionSearchSheet(),
    ),
  );
}

class TransactionSearchSheet extends StatefulWidget {
  const TransactionSearchSheet({super.key});

  @override
  State<TransactionSearchSheet> createState() => _TransactionSearchSheetState();
}

class _TransactionSearchSheetState extends State<TransactionSearchSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  var _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet(
      showDragHandle: true,
      topMargin: 80,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: [
            _SearchTextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (value) => setState(() => _query = value),
              onClear: () {
                _controller.clear();
                setState(() => _query = '');
                _focusNode.requestFocus();
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return BlocBuilder<AccountCubit, AccountState>(
              builder: (context, accountState) {
                return BlocBuilder<
                  RecurringTransactionCubit,
                  RecurringTransactionState
                >(
                  builder: (context, recurringState) {
                    final categoriesByUuid = {
                      for (final category in categoryState.categories)
                        category.uuid: category,
                    };
                    final accountsByUuid = {
                      for (final account in accountState.accounts)
                        account.uuid: account,
                    };
                    final recurringByUuid = {
                      for (final recurring in recurringState.transactions)
                        recurring.uuid: recurring,
                    };

                    final results = _filterTransactions(
                      transactions: transactionState.transactions,
                      categoriesByUuid: categoriesByUuid,
                      accountsByUuid: accountsByUuid,
                      recurringByUuid: recurringByUuid,
                    );

                    if (_query.trim().isEmpty) {
                      return const _EmptySearchState(
                        text: 'Search transactions',
                        hint:
                            'Try amount, note, category, account, type, or repeat.',
                        showIcon: true,
                      );
                    }

                    if (results.isEmpty) {
                      return const _EmptySearchState(text: 'No results');
                    }

                    final items = _buildListItems(_groupResultsByDate(results));

                    return ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        if (item.date != null) {
                          return Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 0 : 16,
                              bottom: 8,
                            ),
                            child: Text(
                              item.date!,
                              style: context.t.bodySmall?.copyWith(
                                color: context.c.onSecondary,
                              ),
                            ),
                          );
                        }

                        final result = item.result!;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildTransactionCard(
                            context,
                            result,
                            recurringByUuid,
                          ),
                        );
                      },
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

  List<_SearchResult> _filterTransactions({
    required List<TransactionEntity> transactions,
    required Map<String, CategoryEntity> categoriesByUuid,
    required Map<String, AccountEntity> accountsByUuid,
    required Map<String, RecurringTransactionEntity> recurringByUuid,
  }) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final results = <_SearchResult>[];
    for (final transaction in transactions) {
      final category = categoriesByUuid[transaction.categoryUuid];
      final account = accountsByUuid[transaction.accountUuid];
      final toAccount = accountsByUuid[transaction.toAccountUuid];
      final recurring = recurringByUuid[transaction.recurringTemplateUuid];
      final haystack = [
        transaction.amount.toString(),
        transaction.money.formatted,
        transaction.type.label,
        recurring?.frequency.label,
        transaction.note,
        category?.name,
        account?.name,
        toAccount?.name,
        DateFormatter.format(transaction.date),
      ].whereType<String>().join(' ').toLowerCase();

      if (haystack.contains(query)) {
        results.add(
          _SearchResult(
            transaction: transaction,
            category: category,
            account: account,
            toAccount: toAccount,
          ),
        );
      }
    }

    results.sort((a, b) => b.transaction.date.compareTo(a.transaction.date));
    return results;
  }

  Map<String, List<_SearchResult>> _groupResultsByDate(
    List<_SearchResult> results,
  ) {
    final groups = <String, List<_SearchResult>>{};
    for (final item in results) {
      groups
          .putIfAbsent(DateFormatter.format(item.transaction.date), () => [])
          .add(item);
    }
    return groups;
  }

  List<_SearchListItem> _buildListItems(
    Map<String, List<_SearchResult>> groups,
  ) {
    final items = <_SearchListItem>[];

    for (final entry in groups.entries) {
      items.add(_SearchListItem.date(entry.key));
      for (final result in entry.value) {
        items.add(_SearchListItem.result(result));
      }
    }

    return items;
  }

  Widget _buildTransactionCard(
    BuildContext context,
    _SearchResult item,
    Map<String, RecurringTransactionEntity> recurringByUuid,
  ) {
    final recurringTemplate = item.transaction.recurringTemplateUuid == null
        ? null
        : recurringByUuid[item.transaction.recurringTemplateUuid];

    return TransactionCard(
      transaction: item.transaction,
      category: item.category,
      account: item.account,
      toAccount: item.toAccount,
      isRecurring: recurringTemplate != null,
      onTap: () =>
          _openTransactionForm(context, item.transaction, recurringTemplate),
      onEdit: () =>
          _openTransactionForm(context, item.transaction, recurringTemplate),
      onDelete: () => _confirmDelete(context, item),
    );
  }

  Future<void> _confirmDelete(BuildContext context, _SearchResult item) async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: context.l10n.deleteTransaction,
      message: context.l10n.areYouSureDeleteTransaction,
      confirmText: context.l10n.delete,
      cancelText: context.l10n.cancel,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<TransactionCubit>().removeTransaction(item.transaction.uuid);
    }
  }

  void _openTransactionForm(
    BuildContext context,
    TransactionEntity transaction,
    RecurringTransactionEntity? recurringTemplate,
  ) {
    showTransactionFormModal(
      context: context,
      initialType: transaction.type,
      transaction: transaction,
      recurringTemplate: recurringTemplate,
    );
  }
}

class _SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchTextField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(AppIcons.search, size: 16, color: context.c.onSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.l10n.search,
                hintStyle: context.t.bodyMedium?.copyWith(
                  color: context.c.onSecondary,
                ),
                border: InputBorder.none,
                isCollapsed: true,
              ),
              style: context.t.bodyMedium,
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox(width: 12);

              return IconButton(
                onPressed: onClear,
                icon: Icon(AppIcons.close, size: 18),
                color: context.c.onSecondary,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final String text;
  final String? hint;
  final bool showIcon;

  const _EmptySearchState({
    required this.text,
    this.hint,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(AppIcons.banknote, size: 64.0, color: context.c.onSecondary),
            const SizedBox(height: 16.0),
          ],
          Text(
            text,
            style: context.t.titleMedium?.copyWith(
              color: context.c.onSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (hint != null) ...[
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                hint!,
                style: context.t.bodyMedium?.copyWith(
                  color: context.c.onSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchResult {
  final TransactionEntity transaction;
  final CategoryEntity? category;
  final AccountEntity? account;
  final AccountEntity? toAccount;

  const _SearchResult({
    required this.transaction,
    required this.category,
    required this.account,
    required this.toAccount,
  });
}

class _SearchListItem {
  final String? date;
  final _SearchResult? result;

  const _SearchListItem.date(this.date) : result = null;

  const _SearchListItem.result(this.result) : date = null;
}
