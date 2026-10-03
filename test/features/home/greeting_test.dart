import 'package:crowzy_finance/features/home/utils/greeting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('greetingFor', () {
    test('changes at noon and at 6 pm', () {
      expect(greetingFor(DateTime(2026, 10, 3, 0, 0)), 'Good morning');
      expect(greetingFor(DateTime(2026, 10, 3, 11, 59)), 'Good morning');
      expect(greetingFor(DateTime(2026, 10, 3, 12, 0)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 10, 3, 17, 59)), 'Good afternoon');
      expect(greetingFor(DateTime(2026, 10, 3, 18, 0)), 'Good evening');
      expect(greetingFor(DateTime(2026, 10, 3, 23, 59)), 'Good evening');
    });
  });

  group('friendlyName', () {
    test('capitalizes the start of the email address', () {
      expect(friendlyName('kaze@example.com'), 'Kaze');
      expect(friendlyName('KAZE@example.com'), 'KAZE');
    });

    test('stops at the first separator', () {
      expect(friendlyName('kaze.dev@example.com'), 'Kaze');
      expect(friendlyName('kaze_dev@example.com'), 'Kaze');
      expect(friendlyName('kaze+work@example.com'), 'Kaze');
      expect(friendlyName('kaze-dev@example.com'), 'Kaze');
    });

    test('skips a leading separator', () {
      expect(friendlyName('.kaze@example.com'), 'Kaze');
    });

    test('is null when there is nothing usable', () {
      expect(friendlyName(null), isNull);
      expect(friendlyName(''), isNull);
      expect(friendlyName('@example.com'), isNull);
      expect(friendlyName('...@example.com'), isNull);
    });
  });
}
