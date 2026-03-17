import 'package:flutter/material.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_progress_bar.dart';

/// Hero card showing total budget summary
class BudgetSummaryCard extends StatelessWidget {
  final BudgetProgress? totalBudget;
  final String periodLabel;

  const BudgetSummaryCard({
    super.key,
    required this.totalBudget,
    this.periodLabel = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (totalBudget == null) {
      return const SizedBox.shrink();
    }

    final progress = totalBudget!;
    final isExceeded = progress.isExceeded;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period label
          if (periodLabel.isNotEmpty)
            Text(
              periodLabel.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),

          const SizedBox(height: 8),

          // Title
          Text(
            'Total Budget',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 4),

          // Progress bar
          BudgetProgressBar(
            progress: progress,
            height: 10,
          ),

          const SizedBox(height: 12),

          // Amount row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                progress.spentMoney.formatted,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isExceeded ? colors.error : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'of ${progress.limitMoney.formatted}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Summary text
          Row(
            children: [
              Icon(
                isExceeded
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 18,
                color: isExceeded ? colors.error : const Color(0xFF22C55E),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isExceeded
                      ? 'Over by ${progress.overByMoney.formatted}'
                      : '${progress.remainingMoney.formatted} remaining · ${progress.budget.daysRemaining} days left',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isExceeded ? colors.error : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
