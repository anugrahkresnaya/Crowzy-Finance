import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/data/models/wishlist_model.dart';
import 'package:crowzy_finance/features/wishlist/providers/wishlist_provider.dart';
import 'package:crowzy_finance/features/wishlist/ui/add_edit_wishlist_screen.dart';
import 'package:crowzy_finance/features/wishlist/ui/wishlist_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

late List<WishlistModel> _goals;
final List<(String, double)> _contributions = [];
final List<String> _deleted = [];
final List<({String name, double target, DateTime? deadline})> _added = [];
final List<WishlistModel> _updated = [];

class _FakeWishlist extends WishlistList {
  @override
  Future<List<WishlistModel>> build() async => _goals;

  @override
  Future<void> addToCurrentAmount(String id, double amount) async =>
      _contributions.add((id, amount));

  @override
  Future<void> deleteGoal(String id) async => _deleted.add(id);

  @override
  Future<void> addGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
  }) async =>
      _added.add((name: name, target: targetAmount, deadline: deadline));

  @override
  Future<void> updateGoal(WishlistModel goal) async => _updated.add(goal);
}

WishlistModel _goal(String id, String name, double current, double target, {DateTime? deadline}) =>
    WishlistModel(
      id: id,
      userId: 'u1',
      name: name,
      targetAmount: target,
      currentAmount: current,
      deadline: deadline,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _goals = [];
    _contributions.clear();
    _deleted.clear();
    _added.clear();
    _updated.clear();
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [wishlistListProvider.overrideWith(_FakeWishlist.new)],
        child: MaterialApp(theme: AppTheme.dark, home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Wishlist list', () {
    testWidgets('features the first goal in progress and lists the rest', (tester) async {
      _goals = [
        _goal('done', 'Laptop', 20, 20),
        _goal('a', 'Japan trip', 62, 100, deadline: DateTime(2027, 3, 15)),
        _goal('b', 'Camera lens', 12, 100),
      ];
      await pump(tester, const WishlistListScreen());

      expect(find.text('Add contribution'), findsOneWidget);
      expect(find.text('BY MAR 2027'), findsOneWidget);
      expect(find.text('OTHER GOALS'), findsOneWidget);
      expect(find.text('Japan trip'), findsOneWidget);
      expect(find.text('Camera lens'), findsOneWidget);
      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('62%'), findsOneWidget);
    });

    testWidgets('when every goal is complete none is featured', (tester) async {
      _goals = [_goal('done', 'Laptop', 20, 20)];
      await pump(tester, const WishlistListScreen());

      expect(find.text('Add contribution'), findsNothing);
      expect(find.text('OTHER GOALS'), findsNothing);
      expect(find.text('Laptop'), findsOneWidget);
      expect(find.text('Goal reached'), findsOneWidget);
    });

    testWidgets('with no goals it invites you to add one', (tester) async {
      await pump(tester, const WishlistListScreen());

      expect(find.textContaining('No goals yet'), findsOneWidget);
      expect(find.byTooltip('Add goal'), findsOneWidget);
    });

    testWidgets('adds a contribution to the featured goal', (tester) async {
      _goals = [_goal('a', 'Japan trip', 62, 100)];
      await pump(tester, const WishlistListScreen());

      await tester.tap(find.text('Add contribution'));
      await tester.pumpAndSettle();
      expect(find.text('Add to "Japan trip"'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '1500000');
      await tester.pump();
      expect(find.text('1.500.000'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(_contributions, [('a', 1500000.0)]);
    });

    testWidgets('an invalid contribution is refused', (tester) async {
      _goals = [_goal('a', 'Japan trip', 62, 100)];
      await pump(tester, const WishlistListScreen());

      await tester.tap(find.text('Add contribution'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid amount'), findsOneWidget);
      expect(_contributions, isEmpty);
    });

    testWidgets('cancelling the dialog adds nothing', (tester) async {
      _goals = [_goal('a', 'Japan trip', 62, 100)];
      await pump(tester, const WishlistListScreen());

      await tester.tap(find.text('Add contribution'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_contributions, isEmpty);
    });

    testWidgets('tapping another goal adds to that one', (tester) async {
      _goals = [_goal('a', 'Japan trip', 62, 100), _goal('b', 'Camera lens', 12, 100)];
      await pump(tester, const WishlistListScreen());

      await tester.tap(find.text('Camera lens'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '250');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(_contributions, [('b', 250.0)]);
    });

    testWidgets('deleting asks first, then removes the goal', (tester) async {
      _goals = [_goal('a', 'Japan trip', 62, 100)];
      await pump(tester, const WishlistListScreen());

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete goal?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(_deleted, ['a']);
    });

    testWidgets('declining the delete keeps the goal', (tester) async {
      _goals = [_goal('a', 'Japan trip', 62, 100)];
      await pump(tester, const WishlistListScreen());

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_deleted, isEmpty);
    });
  });

  group('Goal form', () {
    testWidgets('saves a new goal with a grouped target and no deadline', (tester) async {
      await pump(tester, const AddEditWishlistScreen());

      expect(find.text('New goal'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextFormField, '').first, 'Camera lens');
      await tester.enterText(find.widgetWithText(TextFormField, '').last, '10000000');
      await tester.pump();
      expect(find.text('10.000.000'), findsOneWidget);

      await tester.tap(find.text('Save goal'));
      await tester.pumpAndSettle();

      expect(_added.single.name, 'Camera lens');
      expect(_added.single.target, 10000000);
      expect(_added.single.deadline, isNull);
    });

    testWidgets('needs a name and a target', (tester) async {
      await pump(tester, const AddEditWishlistScreen());

      await tester.tap(find.text('Save goal'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a name'), findsOneWidget);
      expect(find.text('Enter a valid amount'), findsOneWidget);
      expect(_added, isEmpty);
    });

    testWidgets('editing prefills the form and can clear the deadline', (tester) async {
      final goal = _goal('a', 'Japan trip', 62, 30000000, deadline: DateTime(2027, 3, 15));
      await pump(tester, AddEditWishlistScreen(goal: goal));

      expect(find.text('Edit goal'), findsOneWidget);
      expect(find.text('Japan trip'), findsOneWidget);
      expect(find.text('30.000.000'), findsOneWidget);
      expect(find.text('15 Mar 2027'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear deadline'));
      await tester.pump();
      expect(find.text('None'), findsOneWidget);

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(_updated.single.id, 'a');
      expect(_updated.single.deadline, isNull);
      expect(_updated.single.targetAmount, 30000000);
    });
  });
}
