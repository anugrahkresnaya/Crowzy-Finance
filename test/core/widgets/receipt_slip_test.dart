import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/widgets/receipt_slip.dart';
import 'package:flutter/material.dart';
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
}
