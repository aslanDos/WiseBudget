import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/analytics/presentation/cubit/analytics_state.dart';

class CategoryDonutChart extends StatefulWidget {
  final List<CategoryData> data;
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;
  final ValueChanged<CategoryData>? onCategoryTapped;

  const CategoryDonutChart({
    super.key,
    required this.data,
    required this.selectedType,
    required this.onTypeChanged,
    this.onCategoryTapped,
  });

  @override
  State<CategoryDonutChart> createState() => _CategoryDonutChartState();
}

class _CategoryDonutChartState extends State<CategoryDonutChart> {
  int? _touchedIndex;

  @override
  void didUpdateWidget(CategoryDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedType != widget.selectedType) {
      _touchedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: context.c.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('Categories', style: context.t.titleMedium),
              const Spacer(),
              SizedBox(
                width: 160,
                height: 32,
                child: TypeToggle<TransactionType>(
                  backgroundColor: context.c.secondary,
                  items: TransactionType.values
                      .where((t) => t != TransactionType.transfer)
                      .map(
                        (t) => TypeToggleItem(
                          value: t,
                          label: t.label,
                          icon: t.icon,
                          size: 10,
                          selectedBackgroundColor: t.backgroundColor,
                          selectedForegroundColor: t.backgroundColor,
                        ),
                      )
                      .toList(),
                  selected: widget.selectedType,
                  onChanged: widget.onTypeChanged,
                  selectedBackgroundColor: (type) =>
                      type == TransactionType.expense
                      ? AppColors.red
                      : AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.data.isEmpty)
            _EmptyState(type: widget.selectedType)
          else ...[
            // Donut chart centred
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 42,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent) {
                          final index =
                              response?.touchedSection?.touchedSectionIndex;
                          setState(() {
                            _touchedIndex = _touchedIndex == index
                                ? null
                                : index;
                          });
                        }
                      },
                    ),
                    sections: List.generate(widget.data.length, (i) {
                      final d = widget.data[i];
                      final isTouched = i == _touchedIndex;
                      return PieChartSectionData(
                        value: d.amount,
                        color: d.color,
                        radius: isTouched ? 28 : 22,
                        showTitle: false,
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Category cards
            ...List.generate(widget.data.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _CategoryCard(
                  data: widget.data[i],
                  highlighted: _touchedIndex == null || _touchedIndex == i,
                  onTap: widget.onCategoryTapped != null
                      ? () => widget.onCategoryTapped!(widget.data[i])
                      : null,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryData data;
  final bool highlighted;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.data,
    required this.highlighted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: highlighted ? 1.0 : 0.35,
      child: Pressable(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.c.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ColoredIconBox(
                icon: data.icon,
                color: data.color,
                size: 20,
                padding: 8,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.name,
                      style: context.t.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: data.percentage,
                        minHeight: 4,
                        backgroundColor: data.color.withAlpha(0x28),
                        valueColor: AlwaysStoppedAnimation<Color>(data.color),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatCompact(data.amount, data.currency),
                    style: context.t.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.c.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(data.percentage * 100).toStringAsFixed(1)}%',
                    style: context.t.labelSmall?.copyWith(
                      color: context.c.onSurface.withAlpha(0x80),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCompact(double value, String currency) {
    final formatted = value.toStringAsFixed(2);
    return currency.isNotEmpty ? '$formatted $currency' : formatted;
  }
}

class _EmptyState extends StatelessWidget {
  final TransactionType type;

  const _EmptyState({required this.type});

  @override
  Widget build(BuildContext context) {
    final label = type == TransactionType.expense ? 'expense' : 'income';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          'No $label data for this period',
          style: context.t.bodySmall?.copyWith(
            color: context.c.onSurface.withAlpha(0x60),
          ),
        ),
      ),
    );
  }
}
