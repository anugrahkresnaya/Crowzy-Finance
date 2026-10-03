import 'package:crowzy_finance/core/utils/amount_input.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = ThousandsInputFormatter();

  TextEditingValue value(String text, [int? cursor]) => TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: cursor ?? text.length),
      );

  TextEditingValue type(String from, String to, [int? cursor]) =>
      formatter.formatEditUpdate(value(from), value(to, cursor));

  group('group', () {
    test('adds a dot every three digits from the right', () {
      expect(ThousandsInputFormatter.group(''), '');
      expect(ThousandsInputFormatter.group('5'), '5');
      expect(ThousandsInputFormatter.group('999'), '999');
      expect(ThousandsInputFormatter.group('1000'), '1.000');
      expect(ThousandsInputFormatter.group('12480000'), '12.480.000');
      expect(ThousandsInputFormatter.group('1234567'), '1.234.567');
    });
  });

  group('parse', () {
    test('reads a grouped amount back as a number', () {
      expect(ThousandsInputFormatter.parse('85.000'), 85000);
      expect(ThousandsInputFormatter.parse('12.480.000'), 12480000);
      expect(ThousandsInputFormatter.parse('7'), 7);
    });

    test('is null for empty or invalid text', () {
      expect(ThousandsInputFormatter.parse(''), isNull);
      expect(ThousandsInputFormatter.parse('  '), isNull);
      expect(ThousandsInputFormatter.parse('abc'), isNull);
    });
  });

  group('typing', () {
    test('groups digits as they are entered', () {
      expect(type('', '8').text, '8');
      expect(type('85', '850').text, '850');
      expect(type('850', '8500').text, '8.500');
      expect(type('8.500', '8.5000').text, '85.000');
    });

    test('regroups after a deletion', () {
      expect(type('85.000', '85.00').text, '8.500');
      expect(type('8.500', '8.50').text, '850');
      expect(type('8', '').text, '');
    });

    test('drops anything that is not a digit', () {
      expect(type('', 'Rp 12abc').text, '12');
      expect(type('12', '12,5').text, '125');
    });

    test('a pasted grouped number is kept as is', () {
      expect(type('', '12.480.000').text, '12.480.000');
    });

    test('leading zeros are removed', () {
      expect(type('', '0').text, '');
      expect(type('', '007').text, '7');
      expect(type('5', '05').text, '5');
    });

    test('rejects input beyond the digit limit', () {
      const small = ThousandsInputFormatter(maxDigits: 4);
      final old = value('1.234');
      expect(small.formatEditUpdate(old, value('12.345')).text, '1.234');
    });
  });

  group('cursor', () {
    test('stays at the end when typing at the end', () {
      final result = type('8.500', '8.5000');
      expect(result.text, '85.000');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('keeps its place among the digits when a dot appears before it', () {
      // "1.234" with a 5 typed after the 1 (cursor between 1 and the dot).
      final result = type('1.234', '15.234', 2);
      expect(result.text, '15.234');
      expect(result.selection.baseOffset, 2); // right after the 5
    });

    test('keeps its place when regrouping moves a dot', () {
      // "12.345" with the 1 deleted: digits 2345 -> "2.345", cursor at the start.
      final result = type('12.345', '2.345', 0);
      expect(result.text, '2.345');
      expect(result.selection.baseOffset, 0);
    });
  });
}
