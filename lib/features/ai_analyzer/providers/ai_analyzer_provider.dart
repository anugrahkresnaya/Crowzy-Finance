import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers/supabase_provider.dart';
import '../../../data/models/ai_transaction_suggestion.dart';
import '../repository/ai_analyzer_repository.dart';

part 'ai_analyzer_provider.g.dart';

@riverpod
AiAnalyzerRepository aiAnalyzerRepository(Ref ref) {
  return AiAnalyzerRepository(ref.watch(supabaseClientProvider));
}

@riverpod
class TransactionParser extends _$TransactionParser {
  @override
  AsyncValue<AiTransactionSuggestion?> build() => const AsyncData(null);

  Future<void> parse(String text) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(aiAnalyzerRepositoryProvider).parseTransactionText(text),
    );
  }

  void reset() {
    state = const AsyncData(null);
  }
}
