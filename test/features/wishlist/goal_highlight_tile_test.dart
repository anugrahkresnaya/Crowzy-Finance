import 'package:crowzy_finance/data/models/wishlist_model.dart';
import 'package:crowzy_finance/features/wishlist/ui/widgets/goal_highlight_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 10, 3);

  WishlistModel goal({double current = 62, double target = 100, String name = 'Japan trip'}) =>
      WishlistModel(
        id: 'g1',
        userId: 'u1',
        name: name,
        targetAmount: target,
        currentAmount: current,
        createdAt: now,
        updatedAt: now,
      );

  Future<void> pump(WidgetTester tester, GoalHighlightTile tile) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: 170, child: tile)))),
      );

  testWidgets('shows the goal name in capitals and the percentage', (tester) async {
    await pump(tester, GoalHighlightTile(goal: goal(), onTap: () {}));

    expect(find.text('JAPAN TRIP'), findsOneWidget);
    expect(find.text('62%'), findsOneWidget);
  });

  testWidgets('rounds the percentage and caps it at 100', (tester) async {
    await pump(tester, GoalHighlightTile(goal: goal(current: 1, target: 3), onTap: () {}));
    expect(find.text('33%'), findsOneWidget);

    await pump(tester, GoalHighlightTile(goal: goal(current: 250, target: 100), onTap: () {}));
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('a goal with no target reads as zero rather than failing', (tester) async {
    await pump(tester, GoalHighlightTile(goal: goal(current: 10, target: 0), onTap: () {}));
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets('a long name is truncated instead of overflowing', (tester) async {
    await pump(
      tester,
      GoalHighlightTile(goal: goal(name: 'A very long goal name that cannot fit'), onTap: () {}),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping opens it', (tester) async {
    var taps = 0;
    await pump(tester, GoalHighlightTile(goal: goal(), onTap: () => taps++));

    await tester.tap(find.text('62%'));

    expect(taps, 1);
  });
}
