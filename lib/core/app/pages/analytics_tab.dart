import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/router/routes.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/layout/app_breakpoints.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/core/shared/widgets/account_chip.dart';
import 'package:wisebuget/core/shared/widgets/period_chip.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_cubit.dart';
import 'package:wisebuget/features/account/presentation/cubit/account_state.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period_l10n.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_cubit.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_state.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/category_detail_state.dart';
import 'package:wisebuget/features/analytics/presentation/widgets/category_donut_chart.dart';
import 'package:wisebuget/features/analytics/presentation/widgets/period_bar_chart.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  late final AnalyticsCubit _analyticsCubit;

  @override
  void initState() {
    super.initState();
    _analyticsCubit = sl<AnalyticsCubit>();
    sl<AccountCubit>().loadAccounts();
    _analyticsCubit.init();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AccountCubit>()),
        BlocProvider.value(value: _analyticsCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          centerTitle: false,
          title: BlocBuilder<AccountCubit, AccountState>(
            builder: (context, accountState) {
              return BlocBuilder<AnalyticsCubit, AnalyticsState>(
                builder: (context, analyticsState) {
                  final selectedUuid = analyticsState.selectedAccountUuid;
                  final selected = accountState.accounts
                      .where((a) => a.uuid == selectedUuid)
                      .firstOrNull;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AccountChip(
                          account: selected,
                          accounts: accountState.accounts,
                          allSelected: selectedUuid == null,
                          onSelected: context
                              .read<AnalyticsCubit>()
                              .selectAccount,
                          onAllSelected: () => context
                              .read<AnalyticsCubit>()
                              .selectAccount(null),
                        ),
                        const SizedBox(width: 8),
                        PeriodChip(
                          selectedPeriod: analyticsState.selectedPeriod,
                          onChanged: context
                              .read<AnalyticsCubit>()
                              .selectPeriod,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        body: BlocBuilder<AnalyticsCubit, AnalyticsState>(
          builder: (context, state) {
            if (state.status == CubitStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == CubitStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? context.l10n.failedToLoad,
                  style: context.t.bodyMedium,
                ),
              );
            }

            if (state.barBuckets.isEmpty && state.categoryBreakdown.isEmpty) {
              return _EmptyState();
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide =
                    constraints.maxWidth >= AppBreakpoints.analyticsWide;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: _AnalyticsContent(
                        state: state,
                        isWide: isWide,
                        onTypeChanged: context
                            .read<AnalyticsCubit>()
                            .selectCategoryType,
                        onCategoryTapped: (categoryData) {
                          context.push(
                            AppRoutes.categoryDetail,
                            extra: CategoryDetailArgs(
                              categoryUuid: categoryData.categoryUuid,
                              categoryName: categoryData.name,
                              categoryColor: categoryData.color,
                              categoryIcon: categoryData.icon,
                              transactionType: state.categoryType,
                              period: state.selectedPeriod,
                              selectedAccountUuid: state.selectedAccountUuid,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final AnalyticsState state;
  final bool isWide;
  final ValueChanged<TransactionType> onTypeChanged;
  final ValueChanged<CategoryData> onCategoryTapped;

  const _AnalyticsContent({
    required this.state,
    required this.isWide,
    required this.onTypeChanged,
    required this.onCategoryTapped,
  });

  bool get _hasChart =>
      state.selectedPeriod.hasChart && state.barBuckets.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCards(state: state),
          const SizedBox(height: 12),
          if (_hasChart) _ChartCard(buckets: state.barBuckets),
          if (_hasChart) const SizedBox(height: 12),
          _DonutSection(
            state: state,
            onTypeChanged: onTypeChanged,
            onCategoryTapped: onCategoryTapped,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCards(state: state),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasChart)
              Expanded(flex: 5, child: _ChartCard(buckets: state.barBuckets)),
            if (_hasChart) const SizedBox(width: 16),
            Expanded(
              flex: 6,
              child: _DonutSection(
                state: state,
                onTypeChanged: onTypeChanged,
                onCategoryTapped: onCategoryTapped,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<BarBucket> buckets;

  const _ChartCard({required this.buckets});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 220, maxHeight: 260),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.incomeAndExpenses, style: context.t.titleMedium),
          const SizedBox(height: 10),
          Expanded(child: PeriodBarChart(data: buckets)),
        ],
      ),
    );
  }
}

class _DonutSection extends StatelessWidget {
  final AnalyticsState state;
  final ValueChanged<TransactionType> onTypeChanged;
  final ValueChanged<CategoryData> onCategoryTapped;

  const _DonutSection({
    required this.state,
    required this.onTypeChanged,
    required this.onCategoryTapped,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryDonutChart(
      data: state.categoryBreakdown,
      selectedType: state.categoryType,
      onTypeChanged: onTypeChanged,
      onCategoryTapped: onCategoryTapped,
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final AnalyticsState state;

  const _SummaryCards({required this.state});

  @override
  Widget build(BuildContext context) {
    final periodLabel = state.selectedPeriod.localizedChipLabel(context.l10n);
    final currency = state.currency;

    return LayoutBuilder(
      builder: (context, constraints) {
        final stackVertically =
            constraints.maxWidth < AppBreakpoints.summaryStack;

        if (stackVertically) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SummaryCard(
                label: context.l10n.income,
                amount: state.totalIncome,
                currency: currency,
                periodLabel: periodLabel,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                label: context.l10n.expense,
                amount: state.totalExpense,
                currency: currency,
                periodLabel: periodLabel,
                color: context.c.error,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: context.l10n.income,
                amount: state.totalIncome,
                currency: currency,
                periodLabel: periodLabel,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: context.l10n.expense,
                amount: state.totalExpense,
                currency: currency,
                periodLabel: periodLabel,
                color: context.c.error,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final String periodLabel;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.periodLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: context.t.bodySmall?.copyWith(
              color: context.c.onSurface.withAlpha(0x99),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatAmount(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.t.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            periodLabel,
            style: context.t.bodySmall?.copyWith(
              color: context.c.onSurface.withAlpha(0x80),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(BuildContext context) {
    final money = Money(amount, currency);
    final useCompact = amount.abs() >= 100000;

    if (useCompact) {
      return money.formattedCompact;
    }

    return money.formatMoney(decimalDigits: 2);
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: 64,
            color: context.c.onSurface.withAlpha(0x33),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noDataYet,
            style: context.t.titleMedium?.copyWith(
              color: context.c.onSurface.withAlpha(0x80),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.addTransactionsToSeeOverview,
            style: context.t.bodySmall?.copyWith(
              color: context.c.onSurface.withAlpha(0x60),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
