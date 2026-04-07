import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

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
    final textColor = isSelected
        ? context.c.onPrimary
        : isToday
        ? context.c.primary
        : isCurrentMonth
        ? context.c.onSurface
        : context.c.onSecondary;

    final backgroundColor = isSelected ? context.c.primary : null;

    final dotColor = isSelected ? context.c.onPrimary : context.c.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: context.t.bodyLarge?.copyWith(
                color: textColor,
                fontWeight: isSelected || isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            if (hasTransaction)
              Container(
                width: 4.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 4.0), // Placeholder to maintain alignment
          ],
        ),
      ),
    );
  }
}
