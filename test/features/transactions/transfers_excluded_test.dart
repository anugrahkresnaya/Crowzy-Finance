import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/data/models/wishlist_model.dart';
import 'package:crowzy_finance/features/wishlist/providers/wishlist_provider.dart';
import 'package:crowzy_finance/features/ai_analyzer/providers/chat_qa_provider.dart';
import 'package:crowzy_finance/features/ai_analyzer/providers/passive_insight_provider.dart';
import 'package:crowzy_finance/features/budgets/providers/budget_provider.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/reports/providers/report_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/transfers.dart';

/// A transfer is two transactions on the server, an expense and an income. They
/// move money between accounts, so nothing that measures spending or earning
/// may count them: not a month summary, a report, a budget, nor the AI.
late List<TransactionModel> _transactions;

class _Transactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;
}

class _Wishlist extends WishlistList {
  @override
  Future<List<WishlistModel>> build() async => const [];
}

class _Categories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => const [];
}

void main() {
  final now = DateTime.now();

  TransactionModel tx(String id, double amount, TransactionType type, {String category = 'food'}) =>
      TransactionModel(
        id: id,
        userId: 'u1',
        amount: amount,
        type: type,
        categoryId: category,
        accountId: 'bca',
        date: now,
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    // 1.000 earned, 100 spent, and a 5.000 transfer in between two accounts.
    _transactions = [
      tx('salary', 1000, TransactionType.income, category: 'salary'),
      tx('lunch', 100, TransactionType.expense),
      ...legsOf(fakeTransfer('t', amount: 5000, date: now)),
    ];
  });

  Future<ProviderContainer> container() async {
    final c = ProviderContainer(overrides: [
      transactionListProvider.overrideWith(_Transactions.new),
      categoryListProvider.overrideWith(_Categories.new),
      wishlistListProvider.overrideWith(_Wishlist.new),
    ]);
    addTearDown(c.dispose);
    c.listen(transactionListProvider, (_, _) {});
    await c.read(transactionListProvider.future);
    return c;
  }

  test('the spending list has no transfer leg, whichever way the leg is recognised', () async {
    _transactions = [
      ..._transactions,
      // A leg that lost its group id but still has the Transfer In category.
      tx('stray', 70, TransactionType.income, category: '00000000-0000-4000-8000-000000000013'),
    ];
    final c = await container();

    expect(c.read(spendingTransactionsProvider).map((t) => t.id), ['salary', 'lunch']);
  });

  test('the month summary counts only the salary and the lunch', () async {
    final c = await container();

    final month = c.read(thisMonthSummaryProvider);
    expect(month.income, 1000);
    expect(month.expense, 100);
  });

  test('the report for the month counts only the salary and the lunch', () async {
    final c = await container();

    final summary = c.read(monthSummaryProvider);
    expect(summary.totalIncome, 1000);
    expect(summary.totalExpense, 100);
  });

  test('budgets see this month\'s spending without the transfer', () async {
    final c = await container();

    expect(c.read(categorySpendThisMonthProvider), {'food': 100});
    expect(c.read(categoryEarnedThisMonthProvider), {'salary': 1000});
  });

  test('the AI is told about the salary and the lunch only, with the true balance', () async {
    final c = await container();

    final context = c.read(chatContextProvider);
    final weekly = context['weekly'] as List;
    final income = weekly.fold<double>(0, (sum, w) => sum + (w['income'] as double));
    final expense = weekly.fold<double>(0, (sum, w) => sum + (w['expense'] as double));

    expect(income, 1000);
    expect(expense, 100);
    expect(context['current_balance'], 900);
  });

  test('the passive insight is the same with or without a transfer', () async {
    final withTransfer = (await container()).read(passiveInsightContextProvider).fingerprint;

    _transactions = _transactions.where((t) => t.transferGroupId == null).toList();
    final without = (await container()).read(passiveInsightContextProvider).fingerprint;

    expect(withTransfer, without);
  });

  test('the home balance still counts everything', () async {
    final c = await container();

    // No accounts here, so it is the transactions alone: 1000 - 100, the two
    // legs cancelling.
    expect(c.read(allTimeBalanceProvider), 900);
  });
}
