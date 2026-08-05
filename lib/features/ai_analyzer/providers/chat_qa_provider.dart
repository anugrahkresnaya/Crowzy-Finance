import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/ai_correction_intent.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/transaction_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../utils/chat_context_builder.dart';
import '../utils/transaction_matcher.dart';
import 'ai_analyzer_provider.dart';

part 'chat_qa_provider.freezed.dart';
part 'chat_qa_provider.g.dart';

@freezed
abstract class ChatQaState with _$ChatQaState {
  const factory ChatQaState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
  }) = _ChatQaState;
}

@riverpod
Map<String, dynamic> chatContext(Ref ref) {
  final transactions = ref.watch(transactionListProvider).value ?? const [];
  final categories = ref.watch(categoryListProvider).value ?? const [];
  final wishlists = ref.watch(wishlistListProvider).value ?? const [];
  final balance = ref.watch(allTimeBalanceProvider);
  return buildChatContext(
    transactions: transactions,
    categories: categories,
    wishlists: wishlists,
    allTimeBalance: balance,
  );
}

sealed class CorrectionOutcome {
  const CorrectionOutcome();

  const factory CorrectionOutcome.notCorrection() = CorrectionNotCorrection;
  const factory CorrectionOutcome.noMatch() = CorrectionNoMatch;
  const factory CorrectionOutcome.single(TransactionModel transaction, AiCorrectionIntent intent) =
      CorrectionSingle;
  const factory CorrectionOutcome.multiple(List<TransactionModel> candidates, AiCorrectionIntent intent) =
      CorrectionMultiple;
}

class CorrectionNotCorrection extends CorrectionOutcome {
  const CorrectionNotCorrection();
}

class CorrectionNoMatch extends CorrectionOutcome {
  const CorrectionNoMatch();
}

class CorrectionSingle extends CorrectionOutcome {
  const CorrectionSingle(this.transaction, this.intent);
  final TransactionModel transaction;
  final AiCorrectionIntent intent;
}

class CorrectionMultiple extends CorrectionOutcome {
  const CorrectionMultiple(this.candidates, this.intent);
  final List<TransactionModel> candidates;
  final AiCorrectionIntent intent;
}

@riverpod
class ChatQa extends _$ChatQa {
  @override
  ChatQaState build() => const ChatQaState();

  void appendUserMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final message = ChatMessage(id: const Uuid().v4(), role: ChatRole.user, content: trimmed);
    state = state.copyWith(messages: [...state.messages, message]);
  }

  void appendAssistantMessage(String text, {bool isError = false}) {
    final message =
        ChatMessage(id: const Uuid().v4(), role: ChatRole.assistant, content: text, isError: isError);
    state = state.copyWith(messages: [...state.messages, message]);
  }

  Future<void> answerQuestion() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final context = ref.read(chatContextProvider);
      final answer = await ref.read(aiAnalyzerRepositoryProvider).askQuestion(
            history: state.messages,
            context: context,
          );
      state = state.copyWith(isLoading: false);
      appendAssistantMessage(answer);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      appendAssistantMessage('$e', isError: true);
    }
  }

  Future<CorrectionOutcome> classifyAndMatch(String text) async {
    if (state.isLoading) return const CorrectionOutcome.notCorrection();
    state = state.copyWith(isLoading: true);
    try {
      final AiCorrectionIntent intent;
      try {
        intent = await ref.read(aiAnalyzerRepositoryProvider).parseCorrectionIntent(text);
      } catch (_) {
        // Fall back to the plain-question path if intent classification fails.
        return const CorrectionOutcome.notCorrection();
      }
      if (!intent.isCorrection) return const CorrectionOutcome.notCorrection();

      final transactions = ref.read(transactionListProvider).value ?? const [];
      final categories = ref.read(categoryListProvider).value ?? const [];
      final candidates = matchCorrectionCandidates(
        intent: intent,
        transactions: transactions,
        categories: categories,
      );

      if (candidates.isEmpty) return const CorrectionOutcome.noMatch();
      if (candidates.length == 1) return CorrectionOutcome.single(candidates.first, intent);
      return CorrectionOutcome.multiple(candidates, intent);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void reset() => state = const ChatQaState();
}
