import 'package:flutter/material.dart';

class DayCell extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool isCurrentMonth;
  final bool hasTransaction;
  final VoidCallback onTap;

  const DayCell({
    super.key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    this.isCurrentMonth = true,
    this.hasTransaction = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color? backgroundColor;
    Color textColor;

    if (isSelected) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isToday) {
      // Today but not selected - just primary text color, no background
      backgroundColor = null;
      textColor = colorScheme.primary;
    } else {
      backgroundColor = null;
      textColor = isCurrentMonth
          ? colorScheme.onSurface
          : colorScheme.outline.withValues(alpha: 0.4);
    }

    // Dot color: white when selected, primary otherwise
    final dotColor = isSelected ? colorScheme.onPrimary : colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: isSelected || isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            if (hasTransaction)
              Container(
                width: 5.0,
                height: 5.0,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5.0), // Placeholder to maintain alignment
          ],
        ),
      ),
    );
  }
}
