import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _day = DateFormat('d MMM yyyy');
  static final _dayShort = DateFormat('d MMM');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _weekday = DateFormat('EEEE');
  static final _monthName = DateFormat('MMMM');
  static final _monthYearShort = DateFormat('MMM yyyy');

  static String day(DateTime date) => _day.format(date);
  static String dayShort(DateTime date) => _dayShort.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String monthName(DateTime date) => _monthName.format(date);
  static String monthYearShort(DateTime date) => _monthYearShort.format(date);
  static String weekday(DateTime date) => _weekday.format(date);

  static final _dayLong = DateFormat('d MMMM');

  /// "1 October"
  static String dayLong(DateTime date) => _dayLong.format(date);

  /// "Today", "Yesterday", or a short date ("1 Oct", with the year when it is
  /// not the current one).
  static String relativeDay(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final days = _calendarDays(today) - _calendarDays(date);
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return date.year == today.year ? dayShort(date) : day(date);
  }

  /// "Today", "Yesterday", or a long date ("1 October", with the year when it
  /// is not the current one).
  static String relativeDayLong(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final days = _calendarDays(today) - _calendarDays(date);
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return date.year == today.year ? dayLong(date) : '${dayLong(date)} ${date.year}';
  }

  /// "Today, 3 October", "Yesterday, 2 October", otherwise "1 October 2026".
  static String relativeDayWithDate(DateTime date, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final days = _calendarDays(today) - _calendarDays(date);
    if (days == 0) return 'Today, ${dayLong(date)}';
    if (days == 1) return 'Yesterday, ${dayLong(date)}';
    return '${dayLong(date)} ${date.year}';
  }

  /// "Just now", "5 minutes ago", "2 hours ago", "Yesterday", then "1 October".
  static String ago(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final elapsed = current.difference(date);
    if (elapsed.inMinutes < 1) return 'Just now';
    if (elapsed.inMinutes < 60) {
      final minutes = elapsed.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    final days = _calendarDays(current) - _calendarDays(date);
    if (days == 0) {
      final hours = elapsed.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (days == 1) return 'Yesterday';
    return date.year == current.year ? dayLong(date) : day(date);
  }

  // Whole days since the epoch for the calendar date, computed in UTC so a
  // daylight-saving change cannot make two adjacent days look zero days apart.
  static int _calendarDays(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1).subtract(const Duration(microseconds: 1));

  static DateTime previousMonth(DateTime date) => DateTime(date.year, date.month - 1);

  static DateTime nextMonth(DateTime date) => DateTime(date.year, date.month + 1);
}
