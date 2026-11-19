import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _format = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static final _plain = NumberFormat.decimalPattern('id_ID');
  static final _percent = NumberFormat.decimalPatternDigits(locale: 'id_ID', decimalDigits: 1);

  static const _minus = '−';

  /// "Rp 12.480.000"
  static String format(num amount) => _format.format(amount);

  /// "12.480.000", without the currency symbol.
  static String number(num amount) => _plain.format(amount.round());

  /// "+18.200.000" for income, "−184.500" for expenses (a true minus sign).
  static String signed(num amount, {required bool income}) =>
      '${income ? '+' : _minus}${number(amount.abs())}';

  /// "+8,4%" or "−3,2%", with a decimal comma.
  static String signedPercent(num percent) =>
      '${percent >= 0 ? '+' : _minus}${_percent.format(percent.abs())}%';
}
