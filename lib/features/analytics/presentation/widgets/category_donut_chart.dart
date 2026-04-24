import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
import 'package:wisebuget/core/shared/layout/app_breakpoints.dart';
import 'package:wisebuget/core/shared/value_obj/money.dart';
import 'package:wisebuget/core/shared/widgets/colored_icon_box.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/core/shared/widgets/type_toggle.dart';
import 'package:wisebuget/core/theme/app_colors.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
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
    if (oldWidget.selectedType != widget.selectedType ||
        oldWidget.data != widget.data) {
      _touchedIndex = null;
    }
  }

  double get _total => widget.data.fold(0.0, (sum, d) => sum + d.amount);

  String get _currency =>
      widget.data.isNotEmpty ? widget.data.first.currency : '';

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < AppBreakpoints.chartHeaderStack;

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
              _Header(
                isCompact: isCompact,
                selectedType: widget.selectedType,
                onTypeChanged: widget.onTypeChanged,
              ),
              const SizedBox(height: 16),
              if (widget.data.isEmpty)
                _EmptyState(type: widget.selectedType)
              else ...[
                Align(
                  child: _DonutWithTotal(
                    data: widget.data,
                    total: _total,
                    currency: _currency,
                    touchedIndex: _touchedIndex,
                    onTouched: (i) => setState(() {
                      _touchedIndex = _touchedIndex == i ? null : i;
                    }),
                  ),
                ),
                const SizedBox(height: 16),
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
      },
    );
  }
}

class _Header extends StatelessWidget {
  final bool isCompact;
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeChanged;

  const _Header({
    required this.isCompact,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final toggle = SizedBox(
      width: isCompact ? double.infinity : 160,
      height: 32,
      child: TypeToggle<TransactionType>(
        backgroundColor: context.c.secondary,
        items: TransactionType.values
            .where(
              (type) =>
                  type != TransactionType.transfer &&
                  type != TransactionType.adjustment,
            )
            .map(
              (type) => TypeToggleItem(
                value: type,
                label: type.label,
                icon: type.icon,
                size: 10,
                selectedBackgroundColor: type.backgroundColor,
                selectedForegroundColor: type.backgroundColor,
              ),
            )
            .toList(),
        selected: selectedType,
        onChanged: onTypeChanged,
        selectedBackgroundColor: (type) =>
            type == TransactionType.expense ? AppColors.red : AppColors.green,
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categories', style: context.t.titleMedium),
          const SizedBox(height: 12),
          toggle,
        ],
      );
    }

    return Row(
      children: [
        Text('Categories', style: context.t.titleMedium),
        const Spacer(),
        toggle,
      ],
    );
  }
}

// ── Donut with stacked center text ──────────────────────────────────────────

class _DonutWithTotal extends StatelessWidget {
  const _DonutWithTotal({
    required this.data,
    required this.total,
    required this.currency,
    required this.touchedIndex,
    required this.onTouched,
  });

  final List<CategoryData> data;
  final double total;
  final String currency;
  final int? touchedIndex;
  final ValueChanged<int> onTouched;

  static const _size = 148.0;
  static const _centerRadius = 46.0;

  @override
  Widget build(BuildContext context) {
    final totalFormatted = currency.isNotEmpty
        ? Money(total, currency).formattedCompact
        : total.toStringAsFixed(0);

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: _centerRadius,
              sectionsSpace: 2,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent) {
                    final index = response?.touchedSection?.touchedSectionIndex;
                    if (index != null) onTouched(index);
                  }
                },
              ),
              sections: List.generate(data.length, (i) {
                final isTouched = i == touchedIndex;
                return PieChartSectionData(
                  value: data[i].amount,
                  color: data[i].color,
                  radius: isTouched ? 30 : 24,
                  showTitle: false,
                );
              }),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: context.t.labelSmall?.copyWith(
                  color: context.c.onSurface.withAlpha(0x80),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                totalFormatted,
                style: context.t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Category card (below the chart) ─────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.data,
    required this.highlighted,
    this.onTap,
  });

  final CategoryData data;
  final bool highlighted;
  final VoidCallback? onTap;

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
    if (currency.isEmpty) return value.toStringAsFixed(2);
    return Money(value, currency).formatted;
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.type});

  final TransactionType type;

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
