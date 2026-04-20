import 'package:wisebuget/core/l10n/app_localizations.dart';

class DateFormatter {
  const DateFormatter._();

  /// Returns the 12 localized month abbreviations (Jan–Dec).
  static List<String> monthAbbreviations(AppLocalizations l10n) => [
    l10n.jan, l10n.feb, l10n.mar, l10n.apr, l10n.mayShort, l10n.jun,
    l10n.jul, l10n.aug, l10n.sep, l10n.oct, l10n.nov, l10n.dec,
  ];

  /// Formats [d] as "day MonthAbbr" (current year) or "day MonthAbbr year".
  static String formatShortDate(DateTime d, AppLocalizations l10n) {
    final months = monthAbbreviations(l10n);
    final now = DateTime.now();
    if (d.year == now.year) return '${d.day} ${months[d.month - 1]}';
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  static String format(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

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

    if (date.year != now.year) {
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    return '${date.day} ${months[date.month - 1]}';
  }
}
