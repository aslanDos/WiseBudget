import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';

class WeekDayLabels extends StatelessWidget {
  const WeekDayLabels({super.key});

  // static const List<String> _weekDays = [
  //   'Mo',
  //   'Tu',
  //   'We',
  //   'Th',
  //   'Fr',
  //   'Sa',
  //   'Su',
  // ];

  @override
  Widget build(BuildContext context) {
    List<String> weekDays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: weekDays
          .map(
            (day) => Expanded(
              child: Center(child: Text(day, style: context.t.titleMedium)),
            ),
          )
          .toList(),
    );
  }
}
