import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _day = DateFormat('d MMM yyyy');
  static final _dayShort = DateFormat('d MMM');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _weekday = DateFormat('EEEE');

  static String day(DateTime date) => _day.format(date);
  static String dayShort(DateTime date) => _dayShort.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String weekday(DateTime date) => _weekday.format(date);

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
