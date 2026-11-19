import 'package:crowzy_finance/data/models/alert_model.dart';
import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/data/models/alert_type.dart';
import 'package:crowzy_finance/features/alerts/ui/widgets/alert_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  AlertModel alert(AlertType type, {DateTime? readAt, String message = 'Dining is up 30%'}) =>
      AlertModel(
        id: 'a1',
        userId: 'u1',
        type: type,
        period: '2026-10',
        message: message,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        readAt: readAt,
      );

  Future<void> pump(WidgetTester tester, AlertTile tile) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: tile)));

  testWidgets('titles each alert type and shows the server message', (tester) async {
    const titles = {
      AlertType.categorySpike: 'Unusual spending',
      AlertType.overspend: 'Overspending',
      AlertType.wishlistOffPace: 'Goal off pace',
      AlertType.incomeDrop: 'Income drop',
      AlertType.budgetLimit: 'Nearing a limit',
      AlertType.incomeReceived: 'Income received',
      AlertType.goalOnTrack: 'Goal on track',
    };

    for (final entry in titles.entries) {
      await pump(tester, AlertTile(alert: alert(entry.key)));
      expect(find.text(entry.value), findsOneWidget, reason: entry.key.name);
      expect(find.text('Dining is up 30%'), findsOneWidget);
    }
  });

  testWidgets('shows how long ago the alert was raised, in capitals', (tester) async {
    await pump(tester, AlertTile(alert: alert(AlertType.categorySpike)));
    expect(find.text('2 HOURS AGO'), findsOneWidget);
  });

  testWidgets('an unread alert is tappable and shows its dot; a read one has none', (tester) async {
    var taps = 0;
    await pump(
      tester,
      AlertTile(alert: alert(AlertType.categorySpike), onTap: () => taps++),
    );
    await tester.tap(find.text('Unusual spending'));
    expect(taps, 1);

    bool hasDot() => find
        .byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
              w.constraints?.maxWidth == 7,
        )
        .evaluate()
        .isNotEmpty;

    expect(hasDot(), isTrue);

    await pump(
      tester,
      AlertTile(alert: alert(AlertType.categorySpike, readAt: DateTime.now())),
    );
    expect(hasDot(), isFalse);
  });

  group('good news', () {
    Color tileColor(WidgetTester tester) {
      final material = tester.widget<Material>(
        find.descendant(of: find.byType(AlertTile), matching: find.byType(Material)).first,
      );
      return material.color!;
    }

    testWidgets('an unread warning is tinted burgundy and unread good news green', (tester) async {
      await pump(tester, AlertTile(alert: alert(AlertType.budgetLimit)));
      expect(tileColor(tester), AppColors.noticeBackground);

      await pump(tester, AlertTile(alert: alert(AlertType.incomeReceived)));
      expect(tileColor(tester), AppColors.hero);

      await pump(tester, AlertTile(alert: alert(AlertType.goalOnTrack)));
      expect(tileColor(tester), AppColors.hero);
    });

    testWidgets('once read, both settle to the plain surface', (tester) async {
      await pump(tester, AlertTile(alert: alert(AlertType.incomeReceived, readAt: DateTime.now())));
      expect(tileColor(tester), AppColors.surface);

      await pump(tester, AlertTile(alert: alert(AlertType.budgetLimit, readAt: DateTime.now())));
      expect(tileColor(tester), AppColors.surface);
    });
  });

  group('AlertType', () {
    test('only income received and goal on track are good news', () {
      final good = AlertType.values.where((t) => t.isGoodNews).toSet();
      expect(good, {AlertType.incomeReceived, AlertType.goalOnTrack});
    });

    test('the new types round-trip through the server\'s values', () {
      const values = {
        'budget_limit': AlertType.budgetLimit,
        'income_received': AlertType.incomeReceived,
        'goal_on_track': AlertType.goalOnTrack,
      };
      for (final entry in values.entries) {
        final model = AlertModel.fromJson({
          'id': 'a1',
          'user_id': 'u1',
          'type': entry.key,
          'period': '2026-10',
          'message': 'm',
          'created_at': '2026-10-03T00:00:00Z',
        });
        expect(model.type, entry.value);
        expect(model.toJson()['type'], entry.key);
      }
    });
  });
}
