import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crowzy_finance/core/theme/app_motion.dart';
import 'package:crowzy_finance/core/widgets/press_scale.dart';

Widget _app(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

double _scale(WidgetTester tester) => tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

void main() {
  testWidgets('scales down while pressed and back up on release', (tester) async {
    await tester.pumpWidget(_app(const PressScale(child: SizedBox(width: 100, height: 60))));
    expect(_scale(tester), 1);

    final gesture = await tester.startGesture(tester.getCenter(find.byType(PressScale)));
    await tester.pump();
    expect(_scale(tester), 0.97);

    await gesture.up();
    await tester.pump();
    expect(_scale(tester), 1);
  });

  testWidgets('returns to full size when the press is cancelled', (tester) async {
    await tester.pumpWidget(_app(const PressScale(child: SizedBox(width: 100, height: 60))));

    final gesture = await tester.startGesture(tester.getCenter(find.byType(PressScale)));
    await tester.pump();
    await gesture.cancel();
    await tester.pump();

    expect(_scale(tester), 1);
  });

  testWidgets('does not swallow the child\'s own taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(PressScale(child: FilledButton(onPressed: () => taps++, child: const Text('Save')))),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('stays at full size when disabled', (tester) async {
    await tester.pumpWidget(
      _app(const PressScale(enabled: false, child: SizedBox(width: 100, height: 60))),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.byType(PressScale)));
    await tester.pump();
    expect(_scale(tester), 1);
    await gesture.up();
  });

  testWidgets('uses the fast token, and no animation when motion is reduced', (tester) async {
    await tester.pumpWidget(_app(const PressScale(child: SizedBox(width: 100, height: 60))));
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration, AppMotion.fast);

    await tester.pumpWidget(
      _app(const PressScale(child: SizedBox(width: 100, height: 60)), disableAnimations: true),
    );
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration, Duration.zero);
  });
}
