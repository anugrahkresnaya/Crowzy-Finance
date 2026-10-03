import 'package:crowzy_finance/core/utils/currency_formatter.dart';
import 'package:crowzy_finance/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter', () {
    test('number groups thousands with dots and has no symbol', () {
      expect(CurrencyFormatter.number(12480000), '12.480.000');
      expect(CurrencyFormatter.number(0), '0');
      expect(CurrencyFormatter.number(999.6), '1.000');
    });

    test('signed uses a plus for income and a true minus for expenses', () {
      expect(CurrencyFormatter.signed(18200000, income: true), '+18.200.000');
      expect(CurrencyFormatter.signed(184500, income: false), '−184.500');
    });

    test('signed ignores the sign of the amount it is given', () {
      expect(CurrencyFormatter.signed(-184500, income: false), '−184.500');
    });

    test('signedPercent uses a decimal comma and a true minus', () {
      expect(CurrencyFormatter.signedPercent(8.4), '+8,4%');
      expect(CurrencyFormatter.signedPercent(-3.2), '−3,2%');
      expect(CurrencyFormatter.signedPercent(0), '+0,0%');
    });
  });

  group('DateFormatter.relativeDay', () {
    final now = DateTime(2026, 10, 3, 9, 30);

    test('same calendar day is Today, even late the previous evening', () {
      expect(DateFormatter.relativeDay(DateTime(2026, 10, 3, 0, 5), now: now), 'Today');
      expect(DateFormatter.relativeDay(DateTime(2026, 10, 2, 23, 55), now: now), 'Yesterday');
    });

    test('older dates are short within this year and full across years', () {
      expect(DateFormatter.relativeDay(DateTime(2026, 10, 1), now: now), '1 Oct');
      expect(DateFormatter.relativeDay(DateTime(2025, 12, 31), now: now), '31 Dec 2025');
    });

    test('is not thrown off by a daylight-saving change', () {
      final afterShift = DateTime(2026, 3, 9, 0, 30);
      expect(
        DateFormatter.relativeDay(DateTime(2026, 3, 8, 23, 30), now: afterShift),
        'Yesterday',
      );
    });
  });

  group('DateFormatter.relativeDayLong', () {
    final now = DateTime(2026, 10, 3, 9, 30);

    test('Today, Yesterday, then a long date', () {
      expect(DateFormatter.relativeDayLong(DateTime(2026, 10, 3), now: now), 'Today');
      expect(DateFormatter.relativeDayLong(DateTime(2026, 10, 2), now: now), 'Yesterday');
      expect(DateFormatter.relativeDayLong(DateTime(2026, 10, 1), now: now), '1 October');
    });

    test('adds the year for other years', () {
      expect(DateFormatter.relativeDayLong(DateTime(2025, 12, 31), now: now), '31 December 2025');
    });
  });

  group('DateFormatter.ago', () {
    final now = DateTime(2026, 10, 3, 12);

    test('minutes', () {
      expect(DateFormatter.ago(now.subtract(const Duration(seconds: 30)), now: now), 'Just now');
      expect(DateFormatter.ago(now.subtract(const Duration(minutes: 1)), now: now), '1 minute ago');
      expect(DateFormatter.ago(now.subtract(const Duration(minutes: 5)), now: now), '5 minutes ago');
    });

    test('hours on the same day', () {
      expect(DateFormatter.ago(now.subtract(const Duration(hours: 1)), now: now), '1 hour ago');
      expect(DateFormatter.ago(now.subtract(const Duration(hours: 2)), now: now), '2 hours ago');
    });

    test('yesterday, then dates', () {
      expect(DateFormatter.ago(DateTime(2026, 10, 2, 10), now: now), 'Yesterday');
      expect(DateFormatter.ago(DateTime(2026, 9, 30), now: now), '30 September');
      expect(DateFormatter.ago(DateTime(2025, 12, 31), now: now), '31 Dec 2025');
    });

    test('a timestamp in the future reads as just now', () {
      expect(DateFormatter.ago(now.add(const Duration(hours: 3)), now: now), 'Just now');
    });
  });
}
