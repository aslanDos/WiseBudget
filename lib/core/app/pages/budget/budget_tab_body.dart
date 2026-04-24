import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/cubit/cubit_status.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/shared/widgets/cubit_error_widget.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_entity.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:wisebuget/features/budget/presentation/cubit/budget_state.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_progress_bar.dart';
import 'package:wisebuget/features/category/domain/entity/category_entity.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_cubit.dart';
import 'package:wisebuget/features/category/presentation/cubit/category_state.dart';

class BudgetTabBody extends StatelessWidget {
  final VoidCallback onAddBudget;
  final ValueChanged<String> onEditBudget;

  const BudgetTabBody({
    super.key,
    required this.onAddBudget,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        if (state.status == CubitStatus.loading ||
            state.status == CubitStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == CubitStatus.failure) {
          return CubitErrorWidget(
            message: state.errorMessage ?? context.l10n.failedToLoadBudgets,
            onRetry: () => context.read<BudgetCubit>().loadBudgets(),
          );
        }
        if (!state.hasBudgets) {
          return _EmptyState(onTap: onAddBudget);
        }

        return BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, catState) {
            return _BudgetList(
              state: state,
              categories: catState.categories,
              onEdit: onEditBudget,
            );
          },
        );
      },
    );
  }
}

class _BudgetList extends StatelessWidget {
  final BudgetState state;
  final List<CategoryEntity> categories;
  final ValueChanged<String> onEdit;

  const _BudgetList({
    required this.state,
    required this.categories,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<BudgetProgress>>{};
    for (final progress in state.sortedBudgets) {
      final label = _groupLabel(context, progress.budget);
      groups.putIfAbsent(label, () => []).add(progress);
    }

    final periodOrder = {
      BudgetPeriod.weekly: 0,
      BudgetPeriod.monthly: 1,
      BudgetPeriod.custom: 2,
    };
    final sortedKeys = groups.keys.toList()
      ..sort((left, right) {
        final leftPeriod = groups[left]!.first.budget.period;
        final rightPeriod = groups[right]!.first.budget.period;
        return periodOrder[leftPeriod]!.compareTo(periodOrder[rightPeriod]!);
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

  String _groupLabel(BuildContext context, BudgetEntity budget) {
    return switch (budget.period) {
      BudgetPeriod.weekly => context.l10n.thisWeek,
      BudgetPeriod.monthly => context.l10n.thisMonth,
      BudgetPeriod.custom => context.l10n.periodCustom,
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
        .where((category) => budget.categoryUuids.contains(category.uuid))
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
            BudgetProgressBar(progress: progress, height: 6),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.spentAmount(progress.spentMoney.formatted),
                  style: context.t.labelSmall?.copyWith(
                    color: context.c.onSurface.withAlpha(0x80),
                  ),
                ),
                Text(
                  isExceeded
                      ? context.l10n.overByAmount(
                          progress.overByMoney.formatted,
                        )
                      : context.l10n.amountLeft(
                          progress.remainingMoney.formatted,
                        ),
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
          for (final category in shown) ...[
            Text(
              category.name,
              style: context.t.labelSmall?.copyWith(
                color: context.c.onSurface.withAlpha(0x60),
              ),
            ),
            if (category != shown.last || extra > 0)
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
            context.l10n.noBudgetsYet,
            style: context.t.titleMedium?.copyWith(
              color: context.c.onSurface.withAlpha(0x80),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.setBudgetToTrack,
            style: context.t.bodySmall?.copyWith(
              color: context.c.onSurface.withAlpha(0x60),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add, size: 18),
            label: Text(context.l10n.createBudget),
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
