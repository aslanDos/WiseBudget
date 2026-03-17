import 'package:flutter/material.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';

/// Card displaying a budget insight (warning, suggestion, info)
class BudgetInsightCard extends StatelessWidget {
  final BudgetInsight insight;
  final VoidCallback? onTap;

  const BudgetInsightCard({
    super.key,
    required this.insight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final (icon, iconColor, bgColor) = switch (insight.type) {
      BudgetInsightType.warning => (
          Icons.warning_amber_rounded,
          colors.error,
          colors.errorContainer.withAlpha(0x33),
        ),
      BudgetInsightType.suggestion => (
          Icons.lightbulb_outline_rounded,
          const Color(0xFFF59E0B),
          const Color(0xFFF59E0B).withAlpha(0x1A),
        ),
      BudgetInsightType.info => (
          Icons.info_outline_rounded,
          colors.primary,
          colors.primaryContainer.withAlpha(0x33),
        ),
    };

    return Card(
      color: bgColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      insight.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
