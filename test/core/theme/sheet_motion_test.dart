import 'package:crowzy_finance/core/theme/app_motion.dart';
import 'package:crowzy_finance/features/reports/ui/widgets/day_receipt_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('AppMotion.sheetAnimation', () {
    Future<AnimationStyle> style(WidgetTester tester, {required bool reduced}) async {
      late AnimationStyle result;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Builder(builder: (context) {
            result = AppMotion.sheetAnimation(context);
            return const SizedBox();
          }),
        ),
      );
      return result;
    }

    testWidgets('opens over 400 ms and closes over a quicker 300 ms, easing out then in', (tester) async {
      final result = await style(tester, reduced: false);

      expect(result.duration, AppMotion.sheetIn);
      expect(result.reverseDuration, AppMotion.sheetOut);
      expect(result.duration, const Duration(milliseconds: 400));
      expect(result.reverseDuration, const Duration(milliseconds: 300));
      expect(result.curve, AppMotion.curveOut);
      expect(result.reverseCurve, AppMotion.curveIn);
    });

    testWidgets('is instant when motion is reduced', (tester) async {
      expect(await style(tester, reduced: true), AnimationStyle.noAnimation);
    });
  });

  group('a real sheet', () {
    Widget app({bool reduced = false}) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDayReceiptSheet(
                  context,
                  date: DateTime(2026, 10, 3),
                  expenses: const [],
                  categoryById: const {},
                  average: 0,
                  onViewInActivity: () {},
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );

    double top(WidgetTester tester) => tester.getTopLeft(find.byType(DayReceiptSheet)).dy;

    Future<void> use(WidgetTester tester, {bool reduced = false}) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(app(reduced: reduced));
    }

    /// Taps open, then lets the route build and its animation take its first tick.
    Future<void> startOpening(WidgetTester tester) async {
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
    }

    testWidgets('slides up while opening and comes to rest', (tester) async {
      await use(tester);

      await startOpening(tester);
      expect(top(tester), greaterThan(844 - 20)); // begins off the bottom edge

      await tester.pump(const Duration(milliseconds: 100));
      final early = top(tester);
      await tester.pump(const Duration(milliseconds: 150));
      final later = top(tester);
      await tester.pump(const Duration(seconds: 3));
      final rest = top(tester);

      expect(early, greaterThan(later));
      expect(later, greaterThan(rest));
      expect(rest, lessThan(844 - 200)); // fully on screen
    });

    testWidgets('is still rising a quarter of a second in, but has gone within 350 ms of closing', (tester) async {
      await use(tester);
      await startOpening(tester);
      await tester.pump(const Duration(milliseconds: 250));
      final stillRising = top(tester);
      await tester.pump(const Duration(seconds: 3));
      final rest = top(tester);
      expect(stillRising, greaterThan(rest + 10));

      await tester.tap(find.text('Close'));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.byType(DayReceiptSheet), findsOneWidget); // still on its way down

      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(DayReceiptSheet), findsNothing);
    });

    testWidgets('with reduced motion it is in place straight away', (tester) async {
      await use(tester, reduced: true);

      await startOpening(tester);
      final quick = top(tester);
      await tester.pumpAndSettle();

      expect(quick, closeTo(top(tester), 0.5));
    });
  });
}
