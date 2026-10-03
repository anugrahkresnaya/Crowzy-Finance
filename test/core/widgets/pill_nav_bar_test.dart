import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crowzy_finance/core/theme/app_motion.dart';
import 'package:crowzy_finance/core/widgets/pill_nav_bar.dart';

Widget _app({
  int selected = 0,
  ValueChanged<int>? onSelected,
  VoidCallback? onAdd,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          // 358 wide: 340 px of track inside the border and padding, so five
          // slots of 68 px each.
          child: SizedBox(
            width: 358,
            child: PillNavBar(
              selectedIndex: selected,
              onSelected: onSelected ?? (_) {},
              onAdd: onAdd ?? () {},
            ),
          ),
        ),
      ),
    ),
  );
}

double _indicatorLeft(WidgetTester tester) =>
    tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).left!;

void main() {
  test('tabs after the second skip over the add slot', () {
    expect(PillNavBar.slotForTab(0), 0);
    expect(PillNavBar.slotForTab(1), 1);
    expect(PillNavBar.slotForTab(2), 3);
    expect(PillNavBar.slotForTab(3), 4);
  });

  testWidgets('exposes four labelled tabs and the add button', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app());

    for (final label in ['Home', 'Activity', 'Reports', 'Ask AI', 'Add transaction']) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    semantics.dispose();
  });

  testWidgets('reports the tapped tab index, not its slot', (tester) async {
    final tapped = <int>[];
    var adds = 0;
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(onSelected: tapped.add, onAdd: () => adds++));

    await tester.tap(find.bySemanticsLabel('Activity'));
    await tester.tap(find.bySemanticsLabel('Reports'));
    await tester.tap(find.bySemanticsLabel('Ask AI'));
    await tester.tap(find.bySemanticsLabel('Add transaction'));

    expect(tapped, [1, 2, 3]);
    expect(adds, 1);
    semantics.dispose();
  });

  testWidgets('the circle sits under the selected tab and glides when it changes', (tester) async {
    await tester.pumpWidget(_app(selected: 0));
    expect(_indicatorLeft(tester), 10); // slot 0: (68 - 48) / 2

    await tester.pumpWidget(_app(selected: 2));
    expect(_indicatorLeft(tester), 3 * 68 + 10); // Reports is in slot 3

    // It is an implicit animation, so it is mid-way after half the glide time.
    await tester.pumpWidget(_app(selected: 0));
    await tester.pump();
    await tester.pump(AppMotion.navGlide ~/ 2);
    final box = tester.getRect(find.byType(AnimatedPositioned));
    expect(box.width, 48);
    await tester.pumpAndSettle();
  });

  testWidgets('uses the glide token, and no animation when motion is reduced', (tester) async {
    await tester.pumpWidget(_app());
    expect(tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).duration, AppMotion.navGlide);

    await tester.pumpWidget(_app(disableAnimations: true));
    expect(tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).duration, Duration.zero);
  });
}
