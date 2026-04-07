import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class WeekDayLabels extends StatelessWidget {
  const WeekDayLabels({super.key});

  static const List<String> _weekDays = [
    'Mo',
    'Tu',
    'We',
    'Th',
    'Fr',
    'Sa',
    'Su',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _weekDays
          .map(
            (day) => Expanded(
              child: Center(child: Text(day, style: context.t.titleMedium)),
            ),
          )
          .toList(),
    );
  }
}
