import 'package:flutter/material.dart';
import 'package:wisebuget/features/budget/domain/entity/budget_progress.dart';

/// Progress bar widget for budget visualization
class BudgetProgressBar extends StatelessWidget {
  final BudgetProgress progress;
  final double height;
  final BorderRadius? borderRadius;

  const BudgetProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final progressColor = switch (progress.status) {
      BudgetProgressStatus.onTrack => const Color(0xFF22C55E),
      BudgetProgressStatus.nearLimit => const Color(0xFFF59E0B),
      BudgetProgressStatus.exceeded => colors.error,
    };

    // Clamp progress to 1.0 for visual representation
    final progressValue = progress.progress.clamp(0.0, 1.0);
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: radius,
      ),
      child: Stack(
        children: [
          // Progress fill
          FractionallySizedBox(
            widthFactor: progressValue,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: radius,
              ),
            ),
          ),
          // Overflow indicator for exceeded budgets
          if (progress.isExceeded)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: colors.error,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(height / 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Large circular progress indicator for budget detail page
class BudgetCircularProgress extends StatelessWidget {
  final BudgetProgress progress;
  final double size;
  final double strokeWidth;

  const BudgetCircularProgress({
    super.key,
    required this.progress,
    this.size = 160,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final progressColor = switch (progress.status) {
      BudgetProgressStatus.onTrack => const Color(0xFF22C55E),
      BudgetProgressStatus.nearLimit => const Color(0xFFF59E0B),
      BudgetProgressStatus.exceeded => colors.error,
    };

    // Clamp progress for circular indicator
    final progressValue = progress.progress.clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                colors.surfaceContainerHighest,
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progressValue,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(progressColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${progress.progressPercent.toStringAsFixed(0)}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
              if (progress.isExceeded)
                Text(
                  'exceeded',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
