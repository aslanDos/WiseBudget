DateTime normalizeCalendarDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime getCalendarWeekStart(DateTime date) {
  return date.subtract(Duration(days: date.weekday - 1));
}

bool isSameCalendarDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

bool hasCalendarMarkerOnDate(
  DateTime date,
  Set<DateTime>? datesWithTransactions,
) {
  if (datesWithTransactions == null) return false;
  return datesWithTransactions.contains(normalizeCalendarDate(date));
}
