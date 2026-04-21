import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:wisebuget/core/constants/app_enums.dart';
import 'package:wisebuget/core/shared/extensions/transaction_type_x.dart';
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

  double get _total =>
      widget.data.fold(0.0, (sum, d) => sum + d.amount);

  String get _currency =>
      widget.data.isNotEmpty ? widget.data.first.currency : '';

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
          // ── Header ──────────────────────────────────────────────────────
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
                      .where(
                        (t) =>
                            t != TransactionType.transfer &&
                            t != TransactionType.adjustment,
                      )
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
            // ── Donut + Legend row ────────────────────────────────────────
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _DonutWithTotal(
                    data: widget.data,
                    total: _total,
                    currency: _currency,
                    touchedIndex: _touchedIndex,
                    onTouched: (i) => setState(() {
                      _touchedIndex = _touchedIndex == i ? null : i;
                    }),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Legend(
                      data: widget.data,
                      touchedIndex: _touchedIndex,
                      currency: _currency,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Category cards ────────────────────────────────────────────
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
                    final index =
                        response?.touchedSection?.touchedSectionIndex;
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

// ── Right-side legend ────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({
    required this.data,
    required this.touchedIndex,
    required this.currency,
  });

  final List<CategoryData> data;
  final int? touchedIndex;
  final String currency;

  String _formatAmount(double amount) {
    if (currency.isEmpty) return amount.toStringAsFixed(0);
    return Money(amount, currency).formattedCompact;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(data.length, (i) {
        final d = data[i];
        final dimmed = touchedIndex != null && touchedIndex != i;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: dimmed ? 0.35 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: d.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    d.name,
                    style: context.t.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatAmount(d.amount),
                  style: context.t.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
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
