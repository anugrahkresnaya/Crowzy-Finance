import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crowzy_finance/core/theme/app_motion.dart';

Widget _withMotion({required bool disableAnimations, required Widget child}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: child,
  );
}

void main() {
  group('AppMotion.stagger', () {
    test('steps 40 ms per row', () {
      expect(AppMotion.stagger(0), Duration.zero);
      expect(AppMotion.stagger(1), const Duration(milliseconds: 40));
      expect(AppMotion.stagger(3), const Duration(milliseconds: 120));
    });

    test('is capped at 8 rows so deep rows never wait', () {
      expect(AppMotion.stagger(8), const Duration(milliseconds: 320));
      expect(AppMotion.stagger(9), const Duration(milliseconds: 320));
      expect(AppMotion.stagger(500), const Duration(milliseconds: 320));
    });

    test('treats a negative index as the first row', () {
      expect(AppMotion.stagger(-3), Duration.zero);
    });
  });

  group('reduced motion', () {
    testWidgets('scaled returns the duration normally', (tester) async {
      late Duration result;
      late bool reduced;
      await tester.pumpWidget(
        _withMotion(
          disableAnimations: false,
          child: Builder(builder: (context) {
            reduced = AppMotion.reduced(context);
            result = AppMotion.scaled(context, AppMotion.slow);
            return const SizedBox();
          }),
        ),
      );
      expect(reduced, isFalse);
      expect(result, AppMotion.slow);
    });

    testWidgets('scaled returns zero when the system disables animations', (tester) async {
      late Duration result;
      late bool reduced;
      await tester.pumpWidget(
        _withMotion(
          disableAnimations: true,
          child: Builder(builder: (context) {
            reduced = AppMotion.reduced(context);
            result = AppMotion.scaled(context, AppMotion.slow);
            return const SizedBox();
          }),
        ),
      );
      expect(reduced, isTrue);
      expect(result, Duration.zero);
    });

    testWidgets('defaults to full motion without a MediaQuery', (tester) async {
      late bool reduced;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: (context) {
            reduced = AppMotion.reduced(context);
            return const SizedBox();
          }),
        ),
      );
      expect(reduced, isFalse);
    });
  });
}
