import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/widgets/receipt_slip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget host(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: child)),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('TornEdgeClipper.outline', () {
    // 336 wide gives 24 teeth of exactly 14: tips at x = 7, 21, ...; notches at 14, 28, ...
    const size = Size(336, 300);

    test('a torn bottom has teeth: solid under a tip, empty in a notch', () {
      final path = TornEdgeClipper.outline(size, top: false, bottom: true);

      expect(path.contains(const Offset(7, 299)), isTrue);
      expect(path.contains(const Offset(14, 299)), isFalse);
      expect(path.contains(const Offset(21, 299)), isTrue);
      expect(path.contains(const Offset(168, 150)), isTrue);
    });

    test('a torn top has teeth pointing up', () {
      final path = TornEdgeClipper.outline(size, top: true, bottom: false);

      expect(path.contains(const Offset(7, 1)), isTrue);
      expect(path.contains(const Offset(14, 1)), isFalse);
      // The bottom is straight, so even a notch position is covered.
      expect(path.contains(const Offset(14, 299)), isTrue);
    });

    test('an edge that is not torn stays straight', () {
      final path = TornEdgeClipper.outline(size, top: false, bottom: false);

      expect(path.contains(const Offset(14, 1)), isTrue);
      expect(path.contains(const Offset(14, 299)), isTrue);
      expect(path.getBounds(), const Rect.fromLTWH(0, 0, 336, 300));
    });

    test('the teeth fit any width, ending on a full tooth at both corners', () {
      final path = TornEdgeClipper.outline(const Size(331, 200), top: false, bottom: true);

      expect(path.getBounds().width, 331);
      expect(path.getBounds().height, 200);
      expect(path.contains(const Offset(0.5, 100)), isTrue);
      expect(path.contains(const Offset(330.5, 100)), isTrue);
    });

    test('a very narrow sheet still gets a path', () {
      final path = TornEdgeClipper.outline(const Size(8, 50), top: true, bottom: true);

      expect(path.getBounds().isEmpty, isFalse);
    });
  });

  test('the clipper reclips only when an edge changes', () {
    expect(const TornEdgeClipper().shouldReclip(const TornEdgeClipper()), isFalse);
    expect(const TornEdgeClipper().shouldReclip(const TornEdgeClipper(top: true)), isTrue);
    expect(const TornEdgeClipper().shouldReclip(const TornEdgeClipper(bottom: false)), isTrue);
  });

  group('ReceiptSlip', () {
    testWidgets('lays its children out on ivory paper', (tester) async {
      await tester.pumpWidget(host(const ReceiptSlip(children: [Text('one'), Text('two')])));

      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
      final paper = tester.widget<Container>(
        find.descendant(of: find.byType(ReceiptSlip), matching: find.byType(Container)).first,
      );
      expect(paper.color, AppColors.paper);
    });

    testWidgets('leaves room for the teeth only on torn edges', (tester) async {
      await tester.pumpWidget(host(const ReceiptSlip(children: [SizedBox(height: 40)])));
      final plain = tester.getSize(find.byType(ReceiptSlip)).height;

      await tester.pumpWidget(host(const ReceiptSlip(tornTop: true, children: [SizedBox(height: 40)])));
      final tornBoth = tester.getSize(find.byType(ReceiptSlip)).height;

      // The default has a torn bottom; adding a torn top adds one tooth row.
      expect(tornBoth - plain, TornEdgeClipper.toothHeight);

      await tester.pumpWidget(
        host(const ReceiptSlip(tornBottom: false, children: [SizedBox(height: 40)])),
      );
      expect(plain - tester.getSize(find.byType(ReceiptSlip)).height, TornEdgeClipper.toothHeight);
    });
  });

  group('parts', () {
    testWidgets('the heading shows a title and a caption', (tester) async {
      await tester.pumpWidget(
        host(const ReceiptSlip(children: [ReceiptHeading(title: 'CROWZY FINANCE', subtitle: 'TRANSACTION RECEIPT')])),
      );

      expect(find.text('CROWZY FINANCE'), findsOneWidget);
      expect(find.text('TRANSACTION RECEIPT'), findsOneWidget);
    });

    testWidgets('a row upper-cases its label and keeps its value as given', (tester) async {
      await tester.pumpWidget(
        host(const ReceiptSlip(children: [ReceiptRow(label: 'Category', value: 'Food')])),
      );

      expect(find.text('CATEGORY'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
    });

    testWidgets('a line shows its title, caption and amount, and skips an empty caption', (tester) async {
      await tester.pumpWidget(
        host(
          const ReceiptSlip(
            children: [
              ReceiptLine(title: 'Groceries', caption: '09:12 · FOOD', amount: '−184.500'),
              ReceiptLine(title: 'Coffee', caption: '', amount: '−38.000'),
            ],
          ),
        ),
      );

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('09:12 · FOOD'), findsOneWidget);
      expect(find.text('−184.500'), findsOneWidget);
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text(''), findsNothing);
    });

    testWidgets('a total shows its label, amount and optional note', (tester) async {
      await tester.pumpWidget(
        host(
          const ReceiptSlip(
            children: [ReceiptTotal(label: 'TOTAL', amount: '−236.500', note: '0,8× YOUR DAILY AVERAGE')],
          ),
        ),
      );

      expect(find.text('TOTAL'), findsOneWidget);
      expect(find.text('−236.500'), findsOneWidget);
      expect(find.text('0,8× YOUR DAILY AVERAGE'), findsOneWidget);

      await tester.pumpWidget(
        host(const ReceiptSlip(children: [ReceiptTotal(label: 'TOTAL', amount: '1')])),
      );
      expect(find.text('0,8× YOUR DAILY AVERAGE'), findsNothing);
    });

    testWidgets('the stamp shows its word', (tester) async {
      await tester.pumpWidget(host(const ReceiptSlip(children: [ReceiptStamp(text: 'DRAFT')])));

      expect(find.text('DRAFT'), findsOneWidget);
    });

    testWidgets('divider, barcode and footer build and fill the width', (tester) async {
      await tester.pumpWidget(
        host(
          const ReceiptSlip(
            children: [ReceiptDivider(), ReceiptBarcode(), ReceiptFooter('THANK YOU FOR TRACKING')],
          ),
        ),
      );

      expect(find.text('THANK YOU FOR TRACKING'), findsOneWidget);
      expect(tester.getSize(find.byType(ReceiptBarcode)).width, greaterThan(250));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the barcode is decoration and is hidden from assistive technology', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(host(const ReceiptSlip(children: [ReceiptBarcode()])));

      expect(
        find.descendant(of: find.byType(ReceiptBarcode), matching: find.byType(ExcludeSemantics)),
        findsWidgets,
      );
      semantics.dispose();
    });
  });

  group('printing', () {
    Widget hostWith(Widget child, {bool reduced = false}) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: child)),
          ),
        );

    List<double> opacities(WidgetTester tester) => tester
        .widgetList<FadeTransition>(
          find.descendant(of: find.byType(ReceiptSlip), matching: find.byType(FadeTransition)),
        )
        .map((f) => f.opacity.value)
        .toList();

    ReceiptSlip slip({int lines = 3, Duration delay = Duration.zero}) => ReceiptSlip(
          animateLines: true,
          linesDelay: delay,
          children: [for (var i = 0; i < lines; i++) Text('line $i')],
        );

    testWidgets('lines are hidden at first and appear one after another', (tester) async {
      await tester.pumpWidget(hostWith(slip(lines: 4)));
      await tester.pump(const Duration(milliseconds: 1));
      expect(opacities(tester), everyElement(lessThan(0.1)));

      // First line (no delay) is in by 300 ms; the fourth (240 ms delay) is not yet.
      await tester.pump(const Duration(milliseconds: 300));
      final mid = opacities(tester);
      expect(mid.first, 1);
      expect(mid.last, lessThan(1));

      await tester.pump(const Duration(milliseconds: 500));
      expect(opacities(tester), everyElement(1));
    });

    testWidgets('the whole sequence waits for the lines delay', (tester) async {
      await tester.pumpWidget(hostWith(slip(delay: const Duration(milliseconds: 700))));

      await tester.pump(const Duration(milliseconds: 600));
      expect(opacities(tester), everyElement(lessThan(0.1)));

      // The delay timer fires during this pump; the fade starts on the next frame.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 400));
      expect(opacities(tester).first, 1);
    });

    testWidgets('a long receipt does not wait for each line in turn', (tester) async {
      await tester.pumpWidget(hostWith(slip(lines: 60)));

      // 8 lines of stagger (640 ms) plus the 250 ms fade, not 60 * 80 ms = 4.8 s.
      await tester.pump(const Duration(milliseconds: 641));
      await tester.pumpAndSettle(
        const Duration(milliseconds: 16),
        EnginePhase.sendSemanticsUpdate,
        const Duration(milliseconds: 400),
      );
      expect(opacities(tester), everyElement(1));
    });

    testWidgets('lines are not animated unless asked', (tester) async {
      await tester.pumpWidget(hostWith(const ReceiptSlip(children: [Text('plain')])));

      expect(
        find.descendant(of: find.byType(ReceiptSlip), matching: find.byType(FadeTransition)),
        findsNothing,
      );
    });

    testWidgets('with reduced motion the lines are simply there', (tester) async {
      await tester.pumpWidget(hostWith(slip(), reduced: true));

      expect(
        find.descendant(of: find.byType(ReceiptSlip), matching: find.byType(FadeTransition)),
        findsNothing,
      );
      expect(find.text('line 0'), findsOneWidget);
    });

    testWidgets('the stamp lands after its delay, large and faint, then settles', (tester) async {
      await tester.pumpWidget(
        hostWith(const ReceiptSlip(children: [ReceiptStamp(text: 'DRAFT', delay: Duration(milliseconds: 500))])),
      );
      double stampOpacity() => tester
          .widget<FadeTransition>(
            find.descendant(of: find.byType(ReceiptStamp), matching: find.byType(FadeTransition)),
          )
          .opacity
          .value;

      await tester.pump(const Duration(milliseconds: 400));
      expect(stampOpacity(), lessThan(0.1));

      await tester.pump(const Duration(milliseconds: 100 + 50)); // the delay elapses
      await tester.pump(const Duration(milliseconds: 400)); // then the stamp lands
      expect(stampOpacity(), 1);
    });

    testWidgets('a stamp without a delay is just there', (tester) async {
      await tester.pumpWidget(hostWith(const ReceiptSlip(children: [ReceiptStamp(text: 'PAID')])));

      expect(
        find.descendant(of: find.byType(ReceiptStamp), matching: find.byType(FadeTransition)),
        findsNothing,
      );
    });

    group('ReceiptPrint', () {
      const paper = SizedBox(key: ValueKey('paper'), width: 200, height: 100);

      testWidgets('feed: starts above its place and slides down into it', (tester) async {
        await tester.pumpWidget(hostWith(const ReceiptPrint(child: paper)));
        double top() => tester.getTopLeft(find.byKey(const ValueKey('paper'))).dy;

        await tester.pump(const Duration(milliseconds: 1)); // the animation starts on this frame
        final start = top();
        await tester.pump(const Duration(milliseconds: 1100));
        final home = top();

        // It begins a full paper-height above where it ends up.
        expect(home - start, closeTo(100, 0.5));
      });

      testWidgets('feed: the paper is clipped, so it is hidden until it emerges', (tester) async {
        await tester.pumpWidget(hostWith(const ReceiptPrint(child: paper)));

        expect(find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(ClipRect)), findsOneWidget);
        await tester.pumpAndSettle();
      });

      testWidgets('feed: reserves its space from the start', (tester) async {
        await tester.pumpWidget(hostWith(const ReceiptPrint(child: paper)));
        final before = tester.getSize(find.byType(ReceiptPrint));
        await tester.pump(const Duration(seconds: 2));

        expect(tester.getSize(find.byType(ReceiptPrint)), before);
        expect(before.height, 100);
      });

      testWidgets('reveal: uncovers the paper from the top down', (tester) async {
        await tester.pumpWidget(
          hostWith(const ReceiptPrint(style: ReceiptPrintStyle.reveal, child: paper)),
        );
        double visibleHeight() {
          final render = tester.renderObject<RenderClipRect>(
            find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(ClipRect)).first,
          );
          return render.clipper!.getClip(const Size(200, 100)).height;
        }

        await tester.pump(const Duration(milliseconds: 1));
        expect(visibleHeight(), lessThan(10));

        await tester.pump(const Duration(milliseconds: 250));
        final partway = visibleHeight();
        expect(partway, greaterThan(10));
        expect(partway, lessThan(100));

        await tester.pump(const Duration(seconds: 1));
        expect(visibleHeight(), 100);
      });

      testWidgets('reveal waits for its delay', (tester) async {
        await tester.pumpWidget(
          hostWith(
            const ReceiptPrint(
              style: ReceiptPrintStyle.reveal,
              delay: Duration(milliseconds: 500),
              child: paper,
            ),
          ),
        );
        RenderClipRect clip() => tester.renderObject<RenderClipRect>(
              find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(ClipRect)).first,
            );

        await tester.pump(const Duration(milliseconds: 400));
        expect(clip().clipper!.getClip(const Size(200, 100)).height, lessThan(1));
        await tester.pump(const Duration(milliseconds: 200)); // the delay elapses
        await tester.pump(const Duration(seconds: 1)); // then it uncovers
        expect(clip().clipper!.getClip(const Size(200, 100)).height, 100);
      });

      testWidgets('enabled: false shows the receipt at once, untouched', (tester) async {
        for (final style in ReceiptPrintStyle.values) {
          await tester.pumpWidget(hostWith(ReceiptPrint(style: style, enabled: false, child: paper)));

          expect(find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(ClipRect)), findsNothing);
          expect(find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(Animate)), findsNothing);
          expect(tester.getTopLeft(find.byKey(const ValueKey('paper'))).dy, 20);
        }
      });

      testWidgets('with reduced motion the receipt is shown at once, untouched', (tester) async {
        for (final style in ReceiptPrintStyle.values) {
          await tester.pumpWidget(
            hostWith(ReceiptPrint(style: style, child: paper), reduced: true),
          );

          expect(
            find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(ClipRect)),
            findsNothing,
          );
          expect(find.byKey(const ValueKey('paper')), findsOneWidget);
          expect(find.descendant(of: find.byType(ReceiptPrint), matching: find.byType(Animate)), findsNothing);
        }
      });
    });
  });
}
