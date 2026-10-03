import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/alert_model.dart';
import 'package:crowzy_finance/data/models/alert_type.dart';
import 'package:crowzy_finance/features/alerts/providers/alert_provider.dart';
import 'package:crowzy_finance/features/alerts/ui/alerts_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

late List<AlertModel> _alerts;
final List<String> _read = [];
int _markAllCalls = 0;

class _FakeAlerts extends AlertList {
  @override
  Future<List<AlertModel>> build() async => _alerts;

  @override
  Future<void> markRead(String id) async {
    _read.add(id);
    _alerts = [for (final a in _alerts) a.id == id ? a.copyWith(readAt: DateTime.now()) : a];
    state = AsyncData(_alerts);
  }

  @override
  Future<void> markAllRead() async {
    _markAllCalls++;
    _alerts = [for (final a in _alerts) a.copyWith(readAt: a.readAt ?? DateTime.now())];
    state = AsyncData(_alerts);
  }
}

AlertModel _alert(String id, String message, {bool read = false}) => AlertModel(
      id: id,
      userId: 'u1',
      type: AlertType.categorySpike,
      period: '2026-10',
      message: message,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      readAt: read ? DateTime.now() : null,
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _alerts = [];
    _read.clear();
    _markAllCalls = 0;
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [alertListProvider.overrideWith(_FakeAlerts.new)],
        child: MaterialApp(theme: AppTheme.dark, home: const AlertsListScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists every alert with its message', (tester) async {
    _alerts = [_alert('a', 'Dining is up 40%'), _alert('b', 'Japan trip is behind', read: true)];
    await pump(tester);

    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Dining is up 40%'), findsOneWidget);
    expect(find.text('Japan trip is behind'), findsOneWidget);
  });

  testWidgets('tapping an unread alert marks it read', (tester) async {
    _alerts = [_alert('a', 'Dining is up 40%')];
    await pump(tester);

    await tester.tap(find.text('Dining is up 40%'));
    await tester.pumpAndSettle();

    expect(_read, ['a']);
  });

  testWidgets('a read alert is not tappable', (tester) async {
    _alerts = [_alert('b', 'Already seen', read: true)];
    await pump(tester);

    await tester.tap(find.text('Already seen'));
    await tester.pumpAndSettle();

    expect(_read, isEmpty);
  });

  testWidgets('Mark all read clears every unread alert and then disables itself', (tester) async {
    _alerts = [_alert('a', 'One'), _alert('b', 'Two')];
    await pump(tester);

    final button = find.widgetWithText(TextButton, 'Mark all read');
    expect(tester.widget<TextButton>(button).onPressed, isNotNull);

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(_markAllCalls, 1);
    expect(tester.widget<TextButton>(button).onPressed, isNull);
  });

  testWidgets('Mark all read is disabled when everything is already read', (tester) async {
    _alerts = [_alert('a', 'Seen', read: true)];
    await pump(tester);

    expect(
      tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark all read')).onPressed,
      isNull,
    );
  });

  testWidgets('with no alerts it explains what will appear', (tester) async {
    await pump(tester);

    expect(find.textContaining('No alerts yet'), findsOneWidget);
  });

  testWidgets('the list stays on screen while an alert is being marked read', (tester) async {
    _alerts = [_alert('a', 'One'), _alert('b', 'Two')];
    await pump(tester);

    await tester.tap(find.text('One'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Two'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
