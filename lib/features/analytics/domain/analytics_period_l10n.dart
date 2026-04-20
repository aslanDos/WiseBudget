import 'package:wisebuget/core/l10n/l10n.dart';
import 'package:wisebuget/features/analytics/domain/analytics_period.dart';

extension AnalyticsPeriodL10n on AnalyticsPeriod {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        TodayPeriod() => l10n.today,
        YesterdayPeriod() => l10n.yesterday,
        ThisWeekPeriod() => l10n.thisWeek,
        ThisMonthPeriod() => l10n.thisMonth,
        PrevMonthPeriod() => l10n.previousMonth,
        ThisYearPeriod() => l10n.thisYear,
        CustomPeriod() => l10n.customRange,
      };

  String localizedChipLabel(AppLocalizations l10n) {
    final abbr = [
      l10n.jan, l10n.feb, l10n.mar, l10n.apr, l10n.mayShort, l10n.jun,
      l10n.jul, l10n.aug, l10n.sep, l10n.oct, l10n.nov, l10n.dec,
    ];
    final now = DateTime.now();
    return switch (this) {
      TodayPeriod() => l10n.today,
      YesterdayPeriod() => l10n.yesterday,
      ThisWeekPeriod() => l10n.thisWeek,
      ThisMonthPeriod() => '${abbr[now.month - 1]} ${now.year}',
      PrevMonthPeriod() => () {
          final m = now.month == 1 ? 12 : now.month - 1;
          final y = now.month == 1 ? now.year - 1 : now.year;
          return '${abbr[m - 1]} $y';
        }(),
      ThisYearPeriod() => '${now.year}',
      CustomPeriod(start: final s, end: final e) => () {
          final sm = abbr[s.month - 1];
          final em = abbr[e.month - 1];
          if (s.year == e.year) return '${s.day} $sm – ${e.day} $em';
          return '${s.day} $sm ${s.year} – ${e.day} $em ${e.year}';
        }(),
    };
  }
}
