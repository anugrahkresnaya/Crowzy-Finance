import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/chat_message.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../utils/chat_context_builder.dart';
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

@riverpod
class ChatQa extends _$ChatQa {
  @override
  ChatQaState build() => const ChatQaState();

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isLoading) return;

    final userMessage = ChatMessage(id: const Uuid().v4(), role: ChatRole.user, content: trimmed);
    state = state.copyWith(messages: [...state.messages, userMessage], isLoading: true);

    try {
      final context = ref.read(chatContextProvider);
      final answer = await ref.read(aiAnalyzerRepositoryProvider).askQuestion(
            history: state.messages,
            context: context,
          );
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(id: const Uuid().v4(), role: ChatRole.assistant, content: answer),
        ],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(id: const Uuid().v4(), role: ChatRole.assistant, content: '$e', isError: true),
        ],
        isLoading: false,
      );
    }
  }

  void reset() => state = const ChatQaState();
}
