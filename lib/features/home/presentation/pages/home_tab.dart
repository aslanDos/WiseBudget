import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/home/presentation/widgets/collapsible_calendar.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_state.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_card.dart';

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  DateTime _selectedDate = DateTime.now();

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
        appBar: AppBar(title: const Text('Home'), centerTitle: true),
        body: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, transactionState) {
            // Extract dates that have transactions
            final datesWithTransactions = _extractDatesWithTransactions(
              transactionState.transactions,
            );

            return Column(
              children: [
                // Calendar
                SafeArea(
                  bottom: false,
                  child: CollapsibleCalendar(
                    selectedDate: _selectedDate,
                    onDateSelected: (date) {
                      setState(() => _selectedDate = date);
                    },
                    datesWithTransactions: datesWithTransactions,
                  ),
                ),

                const SizedBox(height: 10),

                // Transactions for selected date
                Expanded(child: _TransactionsList(selectedDate: _selectedDate)),
              ],
            );
          },
        ),
      ),
    );
  }

  Set<DateTime> _extractDatesWithTransactions(
    List<TransactionEntity> transactions,
  ) {
    return transactions.map((t) {
      // Normalize to midnight to ensure consistent comparison
      return DateTime(t.date.year, t.date.month, t.date.day);
    }).toSet();
  }
}

class _TransactionsList extends StatelessWidget {
  final DateTime selectedDate;

  const _TransactionsList({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, transactionState) {
        if (transactionState.status == TransactionStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (transactionState.status == TransactionStatus.failure) {
          return Center(
            child: Text(
              transactionState.errorMessage ?? 'Failed to load transactions',
            ),
          );
        }

        // Filter transactions for the selected date
        final transactions = transactionState.transactions.where((t) {
          return t.date.year == selectedDate.year &&
              t.date.month == selectedDate.month &&
              t.date.day == selectedDate.day;
        }).toList();

        if (transactions.isEmpty) {
          return _EmptyState(selectedDate: selectedDate);
        }

        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, categoryState) {
            return BlocBuilder<AccountCubit, AccountState>(
              builder: (context, accountState) {
                return ListView.builder(
                  key: const PageStorageKey('home_transactions_list'),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return _TransactionTile(
                      transaction: transaction,
                      categoryState: categoryState,
                      accountState: accountState,
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

class _EmptyState extends StatelessWidget {
  final DateTime selectedDate;

  const _EmptyState({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64.0,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16.0),
          Text(
            'No transactions',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'for ${_formatDate(selectedDate)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryState categoryState;
  final AccountState accountState;

  const _TransactionTile({
    required this.transaction,
    required this.categoryState,
    required this.accountState,
  });

  @override
  Widget build(BuildContext context) {
    // Find category
    final category = categoryState.categories
        .where((c) => c.uuid == transaction.categoryUuid)
        .firstOrNull;

    // Find account
    final account = accountState.accounts
        .where((a) => a.uuid == transaction.accountUuid)
        .firstOrNull;

    return TransactionCard(
      transaction: transaction,
      category: category,
      account: account,
      onTap: () {
        showTransactionFormModal(
          context: context,
          initialType: transaction.type,
          transaction: transaction,
        );
      },
    );
  }
}
