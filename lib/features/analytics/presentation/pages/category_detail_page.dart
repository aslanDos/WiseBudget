import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/category_detail_cubit.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/category_detail_state.dart';
import 'package:wisebuget/features/analytics/presentation/widgets/period_bar_chart.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';
import 'package:wisebuget/features/transaction/domain/entity/transaction_entity.dart';
import 'package:wisebuget/features/transaction/presentation/cubit/transaction_cubit.dart';
import 'package:wisebuget/features/transaction/presentation/pages/transaction_form.dart';
import 'package:wisebuget/features/transaction/presentation/widgets/transaction_card.dart';

class CategoryDetailPage extends StatelessWidget {
  final CategoryDetailArgs args;

  const CategoryDetailPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CategoryDetailCubit>()..init(args)),
        BlocProvider.value(value: sl<CategoryCubit>()..loadCategories()),
        BlocProvider.value(value: sl<AccountCubit>()..loadAccounts()),
      ],
      child: BlocBuilder<CategoryDetailCubit, CategoryDetailState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(args.categoryName, overflow: TextOverflow.ellipsis),
            ),
            body: state.status == CubitStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : _Body(args: args, state: state),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final CategoryDetailArgs args;
  final CategoryDetailState state;

  const _Body({required this.args, required this.state});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, catState) {
        return BlocBuilder<AccountCubit, AccountState>(
          builder: (context, accState) {
            final category = catState.categories
                .where((c) => c.uuid == args.categoryUuid)
                .firstOrNull;

            final sorted = [...state.transactions]
              ..sort((a, b) => b.date.compareTo(a.date));

            final groups = <String, List<TransactionEntity>>{};
            for (final t in sorted) {
              groups.putIfAbsent(DateFormatter.format(t.date), () => []).add(t);
            }

            return CustomScrollView(
              slivers: [
                // Trend chart — hidden for single-day periods or when no data.
                if (args.period.hasChart && state.barBuckets.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: _ChartSection(state: state),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      (args.period.hasChart && state.barBuckets.isNotEmpty)
                          ? 12
                          : 16,
                      16,
                      0,
                    ),
                    child: _TotalCard(state: state),
                  ),
                ),
                if (sorted.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: context.c.onSurface.withAlpha(0x33),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions for this period',
                            style: context.t.bodyMedium?.copyWith(
                              color: context.c.onSurface.withAlpha(0x60),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    sliver: SliverList.list(
                      children: _buildGroups(
                        context,
                        groups,
                        category,
                        accState,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _buildGroups(
    BuildContext context,
    Map<String, List<TransactionEntity>> groups,
    CategoryEntity? category,
    AccountState accState,
  ) {
    final widgets = <Widget>[];
    bool firstGroup = true;

    for (final entry in groups.entries) {
      if (!firstGroup) {
        widgets.add(const SizedBox(height: 16));
      }
      firstGroup = false;

      widgets.add(
        Text(
          entry.key,
          style: context.t.bodySmall?.copyWith(color: context.c.onSecondary),
        ),
      );
      widgets.add(const SizedBox(height: 8));

      for (final t in entry.value) {
        final acc = accState.accounts
            .where((a) => a.uuid == t.accountUuid)
            .firstOrNull;
        final toAcc = accState.accounts
            .where((a) => a.uuid == t.toAccountUuid)
            .firstOrNull;

        widgets.add(
          TransactionCard(
            transaction: t,
            category: category,
            account: acc,
            toAccount: toAcc,
            onTap: () => showTransactionFormModal(
              context: context,
              initialType: t.type,
              transaction: t,
            ),
            onEdit: () => showTransactionFormModal(
              context: context,
              initialType: t.type,
              transaction: t,
            ),
            onDelete: () =>
                sl<TransactionCubit>().removeTransaction(t.uuid),
          ),
        );
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }
}

class _ChartSection extends StatelessWidget {
  final CategoryDetailState state;

  const _ChartSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 190),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Trend', style: context.t.titleMedium),
          const SizedBox(height: 10),
          Expanded(child: PeriodBarChart(data: state.barBuckets)),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final CategoryDetailState state;

  const _TotalCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final formatted = state.periodTotal.toStringAsFixed(2);
    final label = state.currency.isNotEmpty
        ? '$formatted ${state.currency}'
        : formatted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.t.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            'Total',
            style: context.t.labelSmall?.copyWith(
              color: context.c.onSurface.withAlpha(0x80),
            ),
          ),
        ],
      ),
    );
  }
}
