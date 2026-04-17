import 'package:flutter/material.dart';
import 'package:wisebuget/core/shared/icons/app_icons.dart';
import 'package:wisebuget/core/shared/widgets/modal/modal_sheet.dart';
import 'package:wisebuget/core/shared/widgets/pressable.dart';
import 'package:wisebuget/core/theme/extensions/theme_extensions.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';

class PeriodChip extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const PeriodChip({
    super.key,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => showModal(
        context: context,
        builder: (ctx) => _PeriodPickerSheet(
          selectedPeriod: selectedPeriod,
          onChanged: onChanged,
        ),
      ),
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
            Text(selectedPeriod.chipLabel, style: context.t.titleSmall),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PeriodPickerSheet extends StatefulWidget {
  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onChanged;

  const _PeriodPickerSheet({
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  State<_PeriodPickerSheet> createState() => _PeriodPickerSheetState();
}

class _PeriodPickerSheetState extends State<_PeriodPickerSheet> {
  static const _presets = <AnalyticsPeriod>[
    TodayPeriod(),
    YesterdayPeriod(),
    ThisWeekPeriod(),
    ThisMonthPeriod(),
    PrevMonthPeriod(),
    ThisYearPeriod(),
  ];

  late AnalyticsPeriod? _selectedPreset;
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    final p = widget.selectedPeriod;
    if (p is CustomPeriod) {
      _selectedPreset = null;
      _start = p.start;
      _end = p.end;
    } else {
      _selectedPreset = p;
      _start = p.range.start;
      _end = p.range.end;
    }
  }

  void _selectPreset(AnalyticsPeriod period) {
    setState(() {
      _selectedPreset = period;
      _start = period.range.start;
      _end = period.range.end;
    });
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: _end,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedPreset = null;
        _start = picked;
      });
    }
  }

  Future<void> _pickEnd() async {
    final clampedInitial = _end.isAfter(DateTime.now()) ? DateTime.now() : _end;
    final picked = await showDatePicker(
      context: context,
      initialDate: clampedInitial,
      firstDate: _start,
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedPreset = null;
        _end = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  void _save() {
    final period = _selectedPreset ?? CustomPeriod(start: _start, end: _end);
    widget.onChanged(period);
    Navigator.pop(context);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    if (d.year == now.year) return '${d.day} ${months[d.month - 1]}';
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ModalSheet.scrollable(
      title: Text(
        'Choose period',
        style: context.t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presets.map((period) {
                return _PresetChip(
                  label: period.label,
                  isSelected: _selectedPreset == period,
                  onTap: () => _selectPreset(period),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          _DateRow(
            label: 'Start date',
            date: _formatDate(_start),
            onTap: _pickStart,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _DateRow(label: 'End date', date: _formatDate(_end), onTap: _pickEnd),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Save',
                style: context.t.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? context.c.primary.withAlpha(0x18)
              : context.c.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: context.c.primary, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: context.t.bodyMedium?.copyWith(
            color: isSelected ? context.c.primary : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(label, style: context.t.bodyMedium),
            const Spacer(),
            Text(
              date,
              style: context.t.bodyMedium?.copyWith(
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
