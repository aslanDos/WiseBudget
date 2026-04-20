import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/widgets/cubit_error_widget.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_state.dart';
import 'package:wisebuget/features/budget/presentation/pages/budget_detail_page.dart';
import 'package:wisebuget/features/budget/presentation/pages/budget_form_page.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_card.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_empty_state.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_insight_card.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_summary_card.dart';

class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  @override
  void initState() {
    super.initState();
    sl<BudgetCubit>().loadBudgets();
  }

  void _openBudgetForm({String? budgetUuid}) async {
    final result = await showBudgetFormModal(
      context: context,
      budgetUuid: budgetUuid,
    );
    if (result == true) {
      sl<BudgetCubit>().loadBudgets();
    }
  }

  void _openBudgetDetail(String budgetUuid) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BudgetDetailPage(budgetUuid: budgetUuid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<BudgetCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.budgets),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openBudgetForm(),
          child: const Icon(Icons.add),
        ),
        body: BlocBuilder<BudgetCubit, BudgetState>(
          builder: (context, state) {
            if (state.status == CubitStatus.loading) {
              return _buildLoadingState();
            }

            if (state.status == CubitStatus.failure) {
              return _buildErrorState(state.errorMessage);
            }

            if (!state.hasBudgets) {
              return BudgetEmptyState(
                onCreateBudget: () => _openBudgetForm(),
              );
            }

            return _buildBudgetList(state);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String? message) {
    return CubitErrorWidget(
      message: message,
      onRetry: () => sl<BudgetCubit>().loadBudgets(),
    );
  }

  Widget _buildBudgetList(BudgetState state) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async => sl<BudgetCubit>().loadBudgets(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Total Budget Summary Card
          if (state.totalBudget != null) ...[
            BudgetSummaryCard(
              totalBudget: state.totalBudget,
              periodLabel: _getCurrentPeriodLabel(context),
            ),
            const SizedBox(height: 24),
          ],

          // Section header: Your Budgets
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              context.l10n.yourBudgets,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),

          // Budget cards
          ...state.sortedBudgets.map((progress) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BudgetCard(
                  progress: progress,
                  onTap: () => _openBudgetDetail(progress.budget.uuid),
                  onLongPress: () => _openBudgetForm(
                    budgetUuid: progress.budget.uuid,
                  ),
                ),
              )),

          // Insights section
          if (state.hasInsights) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                context.l10n.insights,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            ...state.insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BudgetInsightCard(
                    insight: insight,
                    onTap: insight.budgetUuid != null
                        ? () => _openBudgetDetail(insight.budgetUuid!)
                        : null,
                  ),
                )),
          ],

          // Bottom padding for FAB
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _getCurrentPeriodLabel(BuildContext context) {
    final now = DateTime.now();
    final l10n = context.l10n;
    final months = [
      l10n.january, l10n.february, l10n.march, l10n.april,
      l10n.may, l10n.june, l10n.july, l10n.august,
      l10n.september, l10n.october, l10n.november, l10n.december,
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
}
