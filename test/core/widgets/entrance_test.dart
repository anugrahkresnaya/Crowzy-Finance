import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crowzy_finance/core/theme/app_motion.dart';
import 'package:crowzy_finance/core/widgets/entrance.dart';

Widget _app({required bool disableAnimations, required int index}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Builder(
          builder: (context) => const Text('row').entrance(context, index: index),
        ),
      ),
    ),
  );
}

void main() {
  const frame = Duration(milliseconds: 16);
  const slack = Duration(milliseconds: 100);

  testWidgets('wraps the child in an animation and ends fully visible', (tester) async {
    await tester.pumpWidget(_app(disableAnimations: false, index: 0));
    expect(find.byType(Animate), findsOneWidget);

    await tester.pumpAndSettle(frame, EnginePhase.sendSemanticsUpdate, AppMotion.base + slack);
    expect(find.text('row'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('a deep row finishes within the capped stagger plus one duration', (tester) async {
    await tester.pumpWidget(_app(disableAnimations: false, index: 500));

    // The entrance delay is a timer, which pumpAndSettle does not wait for, so
    // advance the clock by the capped stagger (8 rows = 320 ms, not 500 rows =
    // 20 s). If the delay were not capped its timer would still be pending and
    // the test would fail at teardown.
    await tester.pump(const Duration(milliseconds: 8 * 40) + frame);
    await tester.pumpAndSettle(frame, EnginePhase.sendSemanticsUpdate, AppMotion.base + slack);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('returns the child untouched when motion is reduced', (tester) async {
    await tester.pumpWidget(_app(disableAnimations: true, index: 3));

    expect(find.byType(Animate), findsNothing);
    expect(find.text('row'), findsOneWidget);
  });
}
