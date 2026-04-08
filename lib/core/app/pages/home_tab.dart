import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
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
        body: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, transactionState) {
            // Extract dates that have transactions
            final datesWithTransactions = _extractDatesWithTransactions(
              transactionState.transactions,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Calendar
                  SafeArea(
                    bottom: false,
                    child: Calendar(
                      selectedDate: _selectedDate,
                      onDateSelected: (date) {
                        setState(() => _selectedDate = date);
                      },
                      datesWithTransactions: datesWithTransactions,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _Header(selectedDate: _selectedDate),

                  // Transactions for selected date
                  Expanded(
                    child: _TransactionsList(selectedDate: _selectedDate),
                  ),
                ],
              ),
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
                return ListView.separated(
                  key: const PageStorageKey('home_transactions_list'),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
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
  const _Header({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(DateFormatter.format(selectedDate), style: context.t.titleMedium),
      ],
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
