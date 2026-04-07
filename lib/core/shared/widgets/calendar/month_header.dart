import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class MonthHeader extends StatelessWidget {
  final DateTime focusedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthHeader({
    super.key,
    required this.focusedDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onPrevious,
            child: Icon(Icons.chevron_left, size: 24),
          ),
          Text(_formatMonth(focusedDate), style: context.t.titleMedium),
          GestureDetector(
            onTap: onNext,
            child: Icon(Icons.chevron_right, size: 24),
          ),
        ],
      ),
    );
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
