import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/widgets/button.dart';

/// Empty state widget for when there are no budgets
class BudgetEmptyState extends StatelessWidget {
  final VoidCallback? onCreateBudget;

  const BudgetEmptyState({
    super.key,
    this.onCreateBudget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withAlpha(0x33),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.pie_chart_outline_rounded,
                size: 40,
                color: colors.primary,
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              'Take control of your spending',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              'Create budgets to track and limit expenses by category or account.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // CTA Button
            Button(
              label: 'Create First Budget',
              onPressed: onCreateBudget,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
