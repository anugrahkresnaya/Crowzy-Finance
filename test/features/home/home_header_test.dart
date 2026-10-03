import 'package:crowzy_finance/features/home/ui/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A Saturday morning.
  final morning = DateTime(2026, 10, 3, 9, 15);

  Widget app({
    String? name = 'Kaze',
    int unread = 0,
    VoidCallback? onOpenAlerts,
    VoidCallback? onSignOut,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: HomeHeader(
            name: name,
            unreadAlerts: unread,
            onOpenAlerts: onOpenAlerts ?? () {},
            onSignOut: onSignOut ?? () {},
            now: morning,
          ),
        ),
      ),
    );
  }

  testWidgets('shows the date and a greeting by name', (tester) async {
    await tester.pumpWidget(app());

    expect(find.text('SATURDAY, 3 OCTOBER'), findsOneWidget);
    expect(find.text('Good morning, Kaze'), findsOneWidget);
    expect(find.text('K'), findsOneWidget);
  });

  testWidgets('greets without a name when there is none', (tester) async {
    await tester.pumpWidget(app(name: null));

    expect(find.text('Good morning'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
  });

  testWidgets('the bell announces how many alerts are new', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(app(unread: 2));
    expect(find.bySemanticsLabel('Alerts, 2 new'), findsOneWidget);

    await tester.pumpWidget(app(unread: 0));
    expect(find.bySemanticsLabel('Alerts'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the bell opens the alerts', (tester) async {
    var opened = 0;
    await tester.pumpWidget(app(unread: 1, onOpenAlerts: () => opened++));

    await tester.tap(find.byIcon(Icons.notifications_none_rounded));

    expect(opened, 1);
  });

  testWidgets('the account menu signs the user out', (tester) async {
    var signedOut = 0;
    await tester.pumpWidget(app(onSignOut: () => signedOut++));

    await tester.tap(find.byTooltip('Account menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    expect(signedOut, 1);
  });
}
