import 'package:crowzy_finance/data/models/ai_correction_intent.dart';
import 'package:crowzy_finance/data/models/ai_transaction_suggestion.dart';
import 'package:crowzy_finance/data/models/category_model.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/ai_analyzer/providers/ai_analyzer_provider.dart';
import 'package:crowzy_finance/features/ai_analyzer/providers/chat_qa_provider.dart';
import 'package:crowzy_finance/features/ai_analyzer/repository/ai_analyzer_repository.dart';
import 'package:crowzy_finance/features/categories/providers/category_provider.dart';
import 'package:crowzy_finance/features/transactions/providers/transaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

late List<TransactionModel> _transactions;

class _FakeRepository implements AiAnalyzerRepository {
  @override
  Future<AiCorrectionIntent> parseCorrectionIntent(String text) async => const AiCorrectionIntent(
        isCorrection: true,
        targetDescription: 'the fee',
        newAmount: 3000,
        confidence: AiConfidence.high,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends TransactionList {
  @override
  Future<List<TransactionModel>> build() async => _transactions;
}

class _FakeCategories extends CategoryList {
  @override
  Future<List<CategoryModel>> build() async => const [];
}

TransactionModel _tx(String id, {String? transferId}) => TransactionModel(
      id: id,
      userId: 'u',
      amount: 2500,
      type: TransactionType.expense,
      categoryId: 'food',
      transferId: transferId,
      date: DateTime(2026, 10, 2),
      createdAt: DateTime(2026, 10, 2),
      updatedAt: DateTime(2026, 10, 2),
    );

void main() {
  Future<CorrectionOutcome> classify() async {
    final container = ProviderContainer(overrides: [
      aiAnalyzerRepositoryProvider.overrideWithValue(_FakeRepository()),
      transactionListProvider.overrideWith(_FakeTransactions.new),
      categoryListProvider.overrideWith(_FakeCategories.new),
    ]);
    addTearDown(container.dispose);
    container.listen(chatQaProvider, (_, _) {});
    await container.read(transactionListProvider.future);
    await container.read(categoryListProvider.future);
    return container.read(chatQaProvider.notifier).classifyAndMatch('change the fee to 3000');
  }

  test('a correction can find an ordinary transaction', () async {
    _transactions = [_tx('lunch')];

    expect(await classify(), isA<CorrectionSingle>());
  });

  test('a transfer fee is never a candidate, since it is changed through its transfer', () async {
    _transactions = [_tx('fee', transferId: 't1')];

    expect(await classify(), isA<CorrectionNoMatch>());
  });

  test('with a fee and an ordinary transaction only the ordinary one is offered', () async {
    _transactions = [_tx('fee', transferId: 't1'), _tx('lunch')];

    final outcome = await classify();

    expect(outcome, isA<CorrectionSingle>());
    expect((outcome as CorrectionSingle).transaction.id, 'lunch');
  });
}
