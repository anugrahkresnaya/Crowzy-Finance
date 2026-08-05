import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/ai_correction_intent.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../categories/providers/category_provider.dart';
import '../../../transactions/providers/transaction_provider.dart';
import '../../providers/chat_qa_provider.dart';
import 'chat_message_bubble.dart';
import 'correction_candidate_picker_sheet.dart';
import 'correction_confirm_sheet.dart';

const _exampleQuestions = [
  'How much did I spend on food last week?',
  'How does this month compare to last month?',
  'Am I on pace for my goals?',
];

class ChatQaTab extends ConsumerStatefulWidget {
  const ChatQaTab({super.key});

  @override
  ConsumerState<ChatQaTab> createState() => _ChatQaTabState();
}

class _ChatQaTabState extends ConsumerState<ChatQaTab> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? text]) async {
    final value = (text ?? _textController.text).trim();
    if (value.isEmpty) return;
    FocusScope.of(context).unfocus();
    _textController.clear();

    final notifier = ref.read(chatQaProvider.notifier);
    notifier.appendUserMessage(value);

    final outcome = await notifier.classifyAndMatch(value);
    if (!mounted) return;

    switch (outcome) {
      case CorrectionNotCorrection():
        await notifier.answerQuestion();
      case CorrectionNoMatch():
        notifier.appendAssistantMessage(
          "I couldn't find a matching transaction for that — try editing it manually.",
        );
      case CorrectionSingle(:final transaction, :final intent):
        await _handleMatch(transaction, intent);
      case CorrectionMultiple(:final candidates, :final intent):
        final categories = ref.read(categoryListProvider).value ?? const [];
        final chosen = await showCorrectionCandidatePickerSheet(context, candidates, categories);
        if (chosen != null && mounted) await _handleMatch(chosen, intent);
    }
  }

  Future<void> _handleMatch(TransactionModel transaction, AiCorrectionIntent intent) async {
    if (!mounted) return;
    final result = await showCorrectionConfirmSheet(context, matched: transaction, intent: intent);
    if (result == null || !mounted) return;

    final notifier = ref.read(chatQaProvider.notifier);
    final categories = ref.read(categoryListProvider).value ?? const [];
    final categoryName =
        categories.where((c) => c.id == result.categoryId).map((c) => c.name).firstOrNull ??
            'Uncategorized';

    await ref.read(transactionListProvider.notifier).updateTransaction(
          transaction.copyWith(
            amount: result.amount,
            type: result.type,
            categoryId: result.categoryId,
            date: result.date,
            note: result.note,
          ),
        );

    notifier.appendAssistantMessage(
      'Updated: $categoryName — ${CurrencyFormatter.format(transaction.amount)} → ${CurrencyFormatter.format(result.amount)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatQaProvider, (previous, next) {
      if (next.messages.length != previous?.messages.length || next.isLoading) {
        _scrollToBottom();
      }
    });

    final state = ref.watch(chatQaProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: state.messages.isEmpty
                ? _EmptyState(onExampleTap: _send)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              'Thinking…',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        );
                      }
                      final message = state.messages[index];
                      return ChatMessageBubble(
                        message: message,
                        onRetry: message.isError ? () => _retry(state, index) : null,
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _textController,
                      label: 'Ask about your spending',
                      enabled: !state.isLoading,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: state.isLoading ? null : () => _send(),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _retry(ChatQaState state, int errorIndex) {
    // Find the user message immediately preceding this error bubble and resend it.
    for (var i = errorIndex - 1; i >= 0; i--) {
      if (state.messages[i].role == ChatRole.user) {
        _send(state.messages[i].content);
        return;
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onExampleTap});

  final ValueChanged<String> onExampleTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ask a question about your income, spending, or goals.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final question in _exampleQuestions)
                ActionChip(
                  label: Text(question),
                  onPressed: () => onExampleTap(question),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
