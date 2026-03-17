import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/colors/app_palette.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';
import 'package:wisebuget/features/budget/presentation/widgets/budget_progress_bar.dart';

/// Card widget displaying a single budget with progress
class BudgetCard extends StatelessWidget {
  final BudgetProgress progress;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const BudgetCard({
    super.key,
    required this.progress,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final budget = progress.budget;

    final isExceeded = progress.isExceeded;
    final budgetColor = AppPalette.fromValue(
      budget.colorValue,
      defaultColor: colors.primary,
    );

    return Card(
      color: isExceeded
          ? colors.errorContainer.withAlpha(0x33)
          : colors.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isExceeded
            ? BorderSide(color: colors.error.withAlpha(0x40))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Icon, Name, Amount
              Row(
                children: [
                  // Icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: budgetColor.withAlpha(0x26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      AppIcons.fromCode(budget.iconCode),
                      size: 22,
                      color: budgetColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                budget.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isExceeded) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 18,
                                color: colors.error,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          budget.periodLabel,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount spent
                  Text(
                    progress.spentMoney.formatted,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isExceeded ? colors.error : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar with limit
              Row(
                children: [
                  Expanded(
                    child: BudgetProgressBar(progress: progress),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'of ${progress.limitMoney.formatted}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Remaining text
              Text(
                isExceeded
                    ? 'Over by ${progress.overByMoney.formatted}'
                    : '${progress.remainingMoney.formatted} left',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isExceeded ? colors.error : colors.onSurfaceVariant,
                  fontWeight: isExceeded ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
