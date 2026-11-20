import 'package:crowzy_finance/core/widgets/app_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(double value, {bool disableAnimations = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Center(
          child: SizedBox(width: 200, child: AppProgressBar(value: value)),
        ),
      ),
    ),
  );
}

double _fill(WidgetTester tester) =>
    tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox)).widthFactor!;

void main() {
  testWidgets('starts empty and fills to the value', (tester) async {
    await tester.pumpWidget(_app(0.6));
    expect(_fill(tester), 0);

    await tester.pumpAndSettle();
    expect(_fill(tester), closeTo(0.6, 1e-9));
  });

  testWidgets('clamps values outside 0..1 and ignores NaN', (tester) async {
    await tester.pumpWidget(_app(1.8));
    await tester.pumpAndSettle();
    expect(_fill(tester), 1);

    await tester.pumpWidget(_app(-0.5));
    await tester.pumpAndSettle();
    expect(_fill(tester), 0);

    await tester.pumpWidget(_app(double.nan));
    await tester.pumpAndSettle();
    expect(_fill(tester), 0);
  });

  testWidgets('eases to a new value instead of restarting from empty', (tester) async {
    await tester.pumpWidget(_app(0.2));
    await tester.pumpAndSettle();

    await tester.pumpWidget(_app(0.8));
    await tester.pump();
    expect(_fill(tester), closeTo(0.2, 1e-9)); // still at the old value on the first frame
    await tester.pumpAndSettle();
    expect(_fill(tester), closeTo(0.8, 1e-9));
  });

  testWidgets('shows the full fill straight away when motion is reduced', (tester) async {
    await tester.pumpWidget(_app(0.6, disableAnimations: true));
    await tester.pump();
    expect(_fill(tester), closeTo(0.6, 1e-9));
  });

  testWidgets('exposes the percentage to assistive technology', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_app(0.62));
    await tester.pumpAndSettle();

    expect(tester.getSemantics(find.byType(AppProgressBar)).value, '62%');
    semantics.dispose();
  });
}
