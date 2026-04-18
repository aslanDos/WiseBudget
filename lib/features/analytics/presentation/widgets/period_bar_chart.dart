import 'dart:math' show log, max, pow, ln10;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_state.dart';

class PeriodBarChart extends StatelessWidget {
  final List<BarBucket> data;

  const PeriodBarChart({super.key, required this.data});

  /// Show every N-th label to avoid overlap depending on bucket count.
  int get _labelStep {
    if (data.length <= 12) return 1;
    if (data.length <= 14) return 2;
    if (data.length <= 31) {
      return 5; // daily month view: ~6 evenly spaced labels
    }
    return 7;
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final rawMax = data.fold<double>(0.0, (m, b) {
      final v = b.income > b.expense ? b.income : b.expense;
      return v > m ? v : m;
    });

    final labelMax = _roundedMax(rawMax);
    final chartMax = max(labelMax * 1.15, rawMax <= 0 ? 100.0 : rawMax * 1.05);
    final interval = labelMax / 2;

    return BarChart(
      BarChartData(
        maxY: chartMax,
        groupsSpace: 6,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => context.c.surface,
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(
              color: context.c.onSurface.withAlpha(0x1A),
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (rodIndex != 0) return null;
              final b = data[group.x];
              if (b.income == 0 && b.expense == 0) return null;
              return BarTooltipItem(
                '${b.label}\n',
                context.t.labelSmall!.copyWith(
                  color: context.c.onSurface.withAlpha(0xAA),
                ),
                textAlign: TextAlign.start,
                children: [
                  TextSpan(
                    text: '+${_fmt(b.income, b.currency)}',
                    style: context.t.labelSmall?.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: '-${_fmt(b.expense, b.currency)}',
                    style: context.t.labelSmall?.copyWith(
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: interval,
              getTitlesWidget: (value, meta) {
                if (value > labelMax + 0.5) return const SizedBox.shrink();
                return SizedBox(
                  width: 24,
                  child: Text(
                    _compact(value),
                    style: context.t.labelSmall?.copyWith(
                      color: context.c.onSurface.withAlpha(0x66),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.right,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                // Skip labels to prevent overlap for dense charts.
                if (index % _labelStep != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    data[index].label,
                    style: context.t.labelSmall?.copyWith(
                      fontSize: 10,
                      color: context.c.onSurface.withAlpha(0x80),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: context.c.onSurface.withAlpha(0x20),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (index) {
          final b = data[index];
          return BarChartGroupData(
            x: index,
            groupVertically: false,
            barRods: [
              BarChartRodData(
                toY: b.income,
                color: AppColors.green,
                width: data.length > 20 ? 4 : 7,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
              BarChartRodData(
                toY: b.expense,
                color: AppColors.red,
                width: data.length > 20 ? 4 : 7,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ],
            barsSpace: 2,
          );
        }),
      ),
    );
  }

  double _roundedMax(double maxValue) {
    if (maxValue <= 0) return 100;
    final magnitude = pow(10, (log(maxValue) / ln10).floor()).toDouble();
    final normalized = maxValue / magnitude;
    if (normalized >= 8) return 8 * magnitude;
    if (normalized >= 6) return 6 * magnitude;
    if (normalized >= 4) return 4 * magnitude;
    if (normalized >= 2) return 2 * magnitude;
    return magnitude;
  }

  String _compact(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  String _fmt(double value, String currency) {
    final f = value.toStringAsFixed(2);
    return currency.isNotEmpty ? '$f $currency' : f;
  }
}
