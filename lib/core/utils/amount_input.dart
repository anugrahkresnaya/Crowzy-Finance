import 'package:flutter/services.dart';

/// Groups the digits of a money field as the user types: "1234567" becomes
/// "1.234.567". Only whole amounts are supported.
class ThousandsInputFormatter extends TextInputFormatter {
  const ThousandsInputFormatter({this.maxDigits = 15});

  final int maxDigits;

  /// "12480000" -> "12.480.000"
  static String group(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// The amount a formatted field holds, or null when it is empty or invalid.
  static double? parse(String text) => double.tryParse(text.replaceAll('.', '').trim());

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final cursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    final digitsBeforeCursor = _digits(newValue.text.substring(0, cursor)).length;

    var digits = _digits(newValue.text).replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > maxDigits) return oldValue;

    final grouped = group(digits);
    final keptBeforeCursor = digitsBeforeCursor.clamp(0, digits.length);

    // Put the cursor after the same number of digits as before, now that dots
    // may have been added or removed.
    var offset = 0;
    var seen = 0;
    while (offset < grouped.length && seen < keptBeforeCursor) {
      if (grouped[offset] != '.') seen++;
      offset++;
    }

    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  static String _digits(String text) => text.replaceAll(RegExp(r'\D'), '');
}
