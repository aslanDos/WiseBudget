import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/utils/date_formatter.dart';
import 'package:wisebuget/core/theme/theme_extensions/theme_extensions.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period_l10n.dart';

class PeriodChip extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onChanged;

  static const _presets = <AnalyticsPeriod>[
    TodayPeriod(),
    YesterdayPeriod(),
    ThisWeekPeriod(),
    ThisMonthPeriod(),
    PrevMonthPeriod(),
    ThisYearPeriod(),
  ];

  const PeriodChip({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = selectedPeriod is CustomPeriod;

    return PullDownButton(
      itemBuilder: (context) => [
        ..._presets.map(
          (period) => PullDownMenuItem.selectable(
            selected: selectedPeriod == period,
            title: period.localizedLabel(context.l10n),
            onTap: () => onChanged(period),
          ),
        ),
        // PullDownMenuItem.selectable(
        //   selected: isCustom,
        //   title: context.l10n.customRange,
        //   icon: CupertinoIcons.calendar,
        //   onTap: () => showCupertinoModalPopup(
        //     context: context,
        //     builder: (ctx) => _CustomDateModal(
        //       selectedPeriod: selectedPeriod,
        //       onChanged: onChanged,
        //     ),
        //   ),
        // ),
      ],
      buttonBuilder: (context, showMenu) => GestureDetector(
        onTap: showMenu,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.c.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.calendar, size: 16, color: context.c.primary),
              const SizedBox(width: 8),
              Text(
                selectedPeriod.localizedChipLabel(context.l10n),
                style: context.t.titleSmall,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CustomDateModal extends StatefulWidget {
  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const _CustomDateModal({
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  State<_CustomDateModal> createState() => _CustomDateModalState();
}

class _CustomDateModalState extends State<_CustomDateModal> {
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _start = widget.selectedPeriod.range.start;
    _end = widget.selectedPeriod.range.end;
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: _end,
    );
    if (picked != null && mounted) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final clamped = _end.isAfter(DateTime.now()) ? DateTime.now() : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: clamped,
      firstDate: _start,
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      widget.onChanged(
        CustomPeriod(
          start: _start,
          end: DateTime(picked.year, picked.month, picked.day, 23, 59, 59),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: context.c.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Text(
                        context.l10n.customRange,
                        style: context.t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    _DateRow(
                      label: context.l10n.startDate,
                      date: DateFormatter.formatShortDate(_start, context.l10n),
                      onTap: _pickStart,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _DateRow(
                      label: context.l10n.endDate,
                      date: DateFormatter.formatShortDate(_end, context.l10n),
                      onTap: _pickEnd,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: context.c.surface,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Center(
                      child: Text(
                        context.l10n.cancel,
                        style: context.t.titleMedium?.copyWith(
                          color: context.c.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DateRow extends StatelessWidget {
  final String label;
  final String date;
  final VoidCallback onTap;

  const _DateRow({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(label, style: context.t.bodyLarge),
            const Spacer(),
            Text(
              date,
              style: context.t.bodyLarge?.copyWith(
                color: context.c.onSurface.withAlpha(0x80),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.c.onSurface.withAlpha(0x60),
            ),
          ],
        ),
      ),
    );
  }
}
