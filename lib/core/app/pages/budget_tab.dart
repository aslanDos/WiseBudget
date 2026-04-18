import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/di/dependency_injection.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/action_button.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_state.dart';
import 'package:wisebuget/features/budget/presentation/pages/budget_form_page.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_progress_bar.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';

class BudgetTab extends StatefulWidget {
  const BudgetTab({super.key});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  @override
  void initState() {
    super.initState();
    sl<BudgetCubit>().loadBudgets();
    sl<CategoryCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<BudgetCubit>()),
        BlocProvider.value(value: sl<CategoryCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 16,
          centerTitle: false,
          title: Text('Budgets', style: context.t.headlineMedium),
          actionsPadding: EdgeInsets.only(right: 16),
          actions: [
            ActionButton(
              icon: AppIcons.add,
              onTap: () => _openBudgetForm(context),
            ),
          ],
        ),
        body: BlocBuilder<BudgetCubit, BudgetState>(
          builder: (context, state) {
            if (state.status == BudgetStatus.loading ||
                state.status == BudgetStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == BudgetStatus.failure) {
              return Center(
                child: Text(
                  state.errorMessage ?? 'Failed to load budgets',
                  style: context.t.bodyMedium,
                ),
              );
            }
            if (!state.hasBudgets) {
              return _EmptyState(onTap: () => _openBudgetForm(context));
            }

            return BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, catState) {
                return _BudgetList(
                  state: state,
                  categories: catState.categories,
                  onAdd: () => _openBudgetForm(context),
                  onEdit: (uuid) => _openBudgetForm(context, budgetUuid: uuid),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _openBudgetForm(
    BuildContext context, {
    String? budgetUuid,
  }) async {
    final result = await showBudgetFormModal(
      context: context,
      budgetUuid: budgetUuid,
    );
    if (result == true && mounted) {
      sl<BudgetCubit>().loadBudgets();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BudgetList extends StatelessWidget {
  final BudgetState state;
  final List<CategoryEntity> categories;
  final VoidCallback onAdd;
  final ValueChanged<String> onEdit;

  const _BudgetList({
    required this.state,
    required this.categories,
    required this.onAdd,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    // Group budgets by period label
    final groups = <String, List<BudgetProgress>>{};
    for (final p in state.sortedBudgets) {
      final label = _groupLabel(p.budget);
      groups.putIfAbsent(label, () => []).add(p);
    }

    // Sort group keys: weekly → monthly → custom
    final periodOrder = {
      BudgetPeriod.weekly: 0,
      BudgetPeriod.monthly: 1,
      BudgetPeriod.custom: 2,
    };
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) {
        final pa = groups[a]!.first.budget.period;
        final pb = groups[b]!.first.budget.period;
        return periodOrder[pa]!.compareTo(periodOrder[pb]!);
      });

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        for (final key in sortedKeys) ...[
          _SectionHeader(label: key),
          const SizedBox(height: 8),
          for (final progress in groups[key]!) ...[
            _BudgetCard(
              progress: progress,
              categories: categories,
              onTap: () => onEdit(progress.budget.uuid),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _groupLabel(BudgetEntity budget) {
    return switch (budget.period) {
      BudgetPeriod.weekly => 'This Week',
      BudgetPeriod.monthly => 'This Month',
      BudgetPeriod.custom => 'Custom',
    };
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: context.t.bodySmall?.copyWith(
        color: context.c.onSurface.withAlpha(0x60),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final BudgetProgress progress;
  final List<CategoryEntity> categories;
  final VoidCallback onTap;

  const _BudgetCard({
    required this.progress,
    required this.categories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final budget = progress.budget;
    final color = AppPalette.fromValue(
      budget.colorValue,
      defaultColor: context.c.primary,
    );

    final budgetCategories = categories
        .where((c) => budget.categoryUuids.contains(c.uuid))
        .toList();

    final isExceeded = progress.isExceeded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.c.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: isExceeded
              ? Border.all(color: context.c.error.withAlpha(0x55))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: icon + name + amount
            Row(
              children: [
                ColoredIconBox(
                  icon: AppIcons.fromCode(budget.iconCode),
                  color: color,
                  size: 20,
                  padding: 8,
                  borderRadius: 10,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: context.t.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (budgetCategories.isNotEmpty)
                        _CategoryChips(categories: budgetCategories),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      progress.limitMoney.formatted,
                      style: context.t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      budget.periodLabel,
                      style: context.t.labelSmall?.copyWith(
                        color: context.c.onSurface.withAlpha(0x60),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Progress bar
            BudgetProgressBar(progress: progress, height: 6),
            const SizedBox(height: 8),
            // Spent / remaining row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent ${progress.spentMoney.formatted}',
                  style: context.t.labelSmall?.copyWith(
                    color: context.c.onSurface.withAlpha(0x80),
                  ),
                ),
                Text(
                  isExceeded
                      ? 'Over by ${progress.overByMoney.formatted}'
                      : '${progress.remainingMoney.formatted} left',
                  style: context.t.labelSmall?.copyWith(
                    color: isExceeded
                        ? context.c.error
                        : context.c.onSurface.withAlpha(0x80),
                    fontWeight: isExceeded ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<CategoryEntity> categories;
  const _CategoryChips({required this.categories});

  @override
  Widget build(BuildContext context) {
    final shown = categories.take(3).toList();
    final extra = categories.length - shown.length;

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          for (final cat in shown) ...[
            Text(
              cat.name,
              style: context.t.labelSmall?.copyWith(
                color: context.c.onSurface.withAlpha(0x60),
              ),
            ),
            if (cat != shown.last || extra > 0)
              Text(
                ' · ',
                style: context.t.labelSmall?.copyWith(
                  color: context.c.onSurface.withAlpha(0x40),
                ),
              ),
          ],
          if (extra > 0)
            Text(
              '+$extra',
              style: context.t.labelSmall?.copyWith(
                color: context.c.onSurface.withAlpha(0x60),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.piggyBank,
            size: 56,
            color: context.c.onSurface.withAlpha(0x33),
          ),
          const SizedBox(height: 16),
          Text(
            'No budgets yet',
            style: context.t.titleMedium?.copyWith(
              color: context.c.onSurface.withAlpha(0x80),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set a budget to track your spending',
            style: context.t.bodySmall?.copyWith(
              color: context.c.onSurface.withAlpha(0x60),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create budget'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
