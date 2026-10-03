import 'package:crowzy_finance/core/theme/app_colors.dart';
import 'package:crowzy_finance/core/theme/app_theme.dart';
import 'package:crowzy_finance/core/widgets/app_progress_bar.dart';
import 'package:crowzy_finance/data/models/budget_model.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/auth/providers/auth_provider.dart';
import 'package:crowzy_finance/features/budgets/providers/budget_provider.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/categories/ui/add_edit_category_screen.dart';
import 'package:crowzy_finance/features/categories/ui/category_list_screen.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late List<CategoryModel> _categories;
late List<TransactionModel> _transactions;
late List<BudgetModel> _budgets;
final List<(String, double?)> _limitCalls = [];
final List<String> _deleted = [];
final List<({String name, String icon, TransactionType type})> _added = [];
final List<CategoryModel> _updated = [];

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => _categories;

  @override
  Future<void> deleteCustomCategory(String id) async => _deleted.add(id);

  @override
  Future<void> addCustomCategory({
    required String userId,
    required String name,
    required String icon,
    required TransactionType type,
  }) async =>
      _added.add((name: name, icon: icon, type: type));

  @override
  Future<void> updateCustomCategory(CategoryModel category) async => _updated.add(category);
}

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;
}

class _FakeBudgets extends BudgetList {
  @override
  Future<List<BudgetModel>> build() async => _budgets;

  @override
  Future<void> setLimit(String categoryId, double? limit) async {
    _limitCalls.add((categoryId, limit));
    _budgets = [
      for (final b in _budgets)
        if (b.categoryId != categoryId) b,
      if (limit != null)
        BudgetModel(
          id: 'b-$categoryId',
          userId: 'u1',
          categoryId: categoryId,
          monthlyLimit: limit,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
    ];
    state = AsyncData(_budgets);
  }
}

final _now = DateTime.now();

CategoryModel _cat(String id, String name, {TransactionType type = TransactionType.expense, bool global = true}) =>
    CategoryModel(
      id: id,
      userId: global ? null : 'u1',
      name: name,
      icon: 'category',
      type: type,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

TransactionModel _tx(String id, double amount, String category, {bool income = false}) => TransactionModel(
      id: id,
      userId: 'u1',
      amount: amount,
      type: income ? TransactionType.income : TransactionType.expense,
      categoryId: category,
      date: DateTime(_now.year, _now.month, _now.day, 12),
      createdAt: _now,
      updatedAt: _now,
    );

BudgetModel _budget(String category, double limit) => BudgetModel(
      id: 'b-$category',
      userId: 'u1',
      categoryId: category,
      monthlyLimit: limit,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    _categories = [
      _cat('housing', 'Housing'),
      _cat('food', 'Food'),
      _cat('dining', 'Dining'),
      _cat('hobby', 'Hobby', global: false),
      _cat('salary', 'Salary', type: TransactionType.income),
    ];
    _transactions = [
      _tx('1', 3500000, 'housing'),
      _tx('2', 850000, 'dining'),
      _tx('3', 1240000, 'food'),
      _tx('4', 18200000, 'salary', income: true),
    ];
    _budgets = [_budget('housing', 3500000), _budget('dining', 1000000), _budget('food', 2000000)];
    _limitCalls.clear();
    _deleted.clear();
    _added.clear();
    _updated.clear();
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          categoryListProvider.overrideWith(_FakeCategories.new),
          transactionListProvider.overrideWith(_FakeTransactions.new),
          budgetListProvider.overrideWith(_FakeBudgets.new),
          currentUserProvider.overrideWithValue(
            const User(id: 'u1', appMetadata: {}, userMetadata: {}, aud: '', createdAt: ''),
          ),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: screen),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Color amountColor(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!.color!;

  group('Categories', () {
    testWidgets('lists expense categories, biggest spend first, with limits where set', (tester) async {
      await pump(tester, const CategoryListScreen());

      expect(find.text('SPENT THIS MONTH'), findsOneWidget);
      expect(find.text('Salary'), findsNothing); // income category

      final order = ['Housing', 'Food', 'Dining', 'Hobby'];
      final tops = [for (final n in order) tester.getTopLeft(find.text(n)).dy];
      expect(tops, [...tops]..sort());

      expect(find.text('3.500.000'), findsOneWidget); // Housing's spend
      expect(find.text('of 3.500.000'), findsOneWidget);
      expect(find.text('of 2.000.000'), findsOneWidget);
      expect(find.text('of 1.000.000'), findsOneWidget);
    });

    testWidgets('a category without a limit says so and has no bar', (tester) async {
      await pump(tester, const CategoryListScreen());

      expect(find.text('no limit set'), findsOneWidget); // Hobby
      // Housing, Food and Dining have bars; Hobby does not.
      expect(find.byType(AppProgressBar), findsNWidgets(3));
    });

    testWidgets('warns from 85% of the limit', (tester) async {
      await pump(tester, const CategoryListScreen());

      expect(amountColor(tester, '850.000'), AppColors.expense); // Dining: 85% of 1.000.000
      expect(amountColor(tester, '1.240.000'), AppColors.ivory); // Food: 62%
    });

    testWidgets('spending over the limit also warns and does not break the bar', (tester) async {
      _budgets = [_budget('housing', 1000000)];
      await pump(tester, const CategoryListScreen());

      expect(amountColor(tester, '3.500.000'), AppColors.expense);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a row sets its limit, including on a default category', (tester) async {
      await pump(tester, const CategoryListScreen());

      await tester.tap(find.text('Hobby'));
      await tester.pumpAndSettle();
      expect(find.text('Hobby limit'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '1500000');
      await tester.pump();
      expect(find.text('1.500.000'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(_limitCalls, [('hobby', 1500000.0)]);
      expect(find.text('of 1.500.000'), findsOneWidget);
    });

    testWidgets('the dialog is prefilled and can remove the limit', (tester) async {
      await pump(tester, const CategoryListScreen());

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      expect(find.text('2.000.000'), findsWidgets);

      await tester.tap(find.text('Remove limit'));
      await tester.pumpAndSettle();

      expect(_limitCalls, [('food', null)]);
      expect(find.text('no limit set'), findsNWidgets(2));
    });

    testWidgets('a category with no limit offers no Remove button', (tester) async {
      await pump(tester, const CategoryListScreen());

      await tester.tap(find.text('Hobby'));
      await tester.pumpAndSettle();

      expect(find.text('Remove limit'), findsNothing);
    });

    testWidgets('zero or an empty field both mean no limit', (tester) async {
      await pump(tester, const CategoryListScreen());

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      // The amount field never holds a leading zero, so "0" is just empty.
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.pump();
      expect(tester.widget<TextFormField>(find.byType(TextFormField)).controller!.text, isEmpty);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(_limitCalls, [('food', null)]);

      await tester.tap(find.text('Dining'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(_limitCalls, [('food', null), ('dining', null)]);
    });

    testWidgets('cancelling the dialog changes nothing', (tester) async {
      await pump(tester, const CategoryListScreen());

      await tester.tap(find.text('Food'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(_limitCalls, isEmpty);
    });

    testWidgets('the Income view shows earnings and no limits', (tester) async {
      await pump(tester, const CategoryListScreen());

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('EARNED THIS MONTH'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('18.200.000'), findsOneWidget);
      expect(find.text('this month'), findsOneWidget);
      expect(find.text('no limit set'), findsNothing);
      expect(find.byType(AppProgressBar), findsNothing);
      expect(find.text('Housing'), findsNothing);
    });

    testWidgets('only your own categories have a menu to edit or delete', (tester) async {
      await pump(tester, const CategoryListScreen());

      expect(find.byTooltip('More'), findsOneWidget); // Hobby only

      await tester.tap(find.byTooltip('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete category?'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(_deleted, ['hobby']);
    });

    testWidgets('the add button opens the category form on the current type', (tester) async {
      await pump(tester, const CategoryListScreen());

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Add category'));
      await tester.pumpAndSettle();

      expect(find.text('New category'), findsOneWidget);
    });

    testWidgets('an empty list says so', (tester) async {
      _categories = [];
      await pump(tester, const CategoryListScreen());

      expect(find.text('No categories yet'), findsOneWidget);
    });
  });

  group('Category form', () {
    testWidgets('saves a new category with the chosen type and icon', (tester) async {
      await pump(tester, const AddEditCategoryScreen());

      await tester.enterText(find.byType(TextFormField), '  Books ');
      await tester.tap(find.bySemanticsLabel('school'));
      await tester.pump();
      await tester.tap(find.text('Save category'));
      await tester.pumpAndSettle();

      expect(_added.single.name, 'Books');
      expect(_added.single.icon, 'school');
      expect(_added.single.type, TransactionType.expense);
    });

    testWidgets('needs a name', (tester) async {
      await pump(tester, const AddEditCategoryScreen());

      await tester.tap(find.text('Save category'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
      expect(_added, isEmpty);
    });

    testWidgets('the Income segment saves an income category', (tester) async {
      await pump(tester, const AddEditCategoryScreen());

      await tester.tap(find.text('Income'));
      await tester.pump();
      await tester.enterText(find.byType(TextFormField), 'Freelance');
      await tester.tap(find.text('Save category'));
      await tester.pumpAndSettle();

      expect(_added.single.type, TransactionType.income);
    });

    testWidgets('editing prefills the name and saves the change', (tester) async {
      await pump(tester, AddEditCategoryScreen(category: _cat('hobby', 'Hobby', global: false)));

      expect(find.text('Edit category'), findsOneWidget);
      expect(find.text('Hobby'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Crafts');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(_updated.single.id, 'hobby');
      expect(_updated.single.name, 'Crafts');
    });
  });
}
