import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/entrance.dart';
import '../../../../data/models/ai_correction_intent.dart';
import '../../../../data/models/chat_message.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../categories/providers/category_provider.dart';
import '../../../transactions/providers/transaction_provider.dart';
import '../../providers/chat_qa_provider.dart';
import 'chat_message_bubble.dart';
import 'correction_candidate_picker_sheet.dart';
import 'correction_confirm_sheet.dart';
import 'passive_insight_card.dart';
import 'thinking_dots.dart';

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
        duration: AppMotion.scaled(context, AppMotion.base),
        curve: AppMotion.curveOut,
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
    final hasMessages = state.messages.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
            children: [
              const PassiveInsightCard(),
              if (!hasMessages)
                _EmptyState(onExampleTap: _send)
              else ...[
                const SizedBox(height: 14),
                for (final (index, message) in state.messages.indexed)
                  KeyedSubtree(
                    key: ValueKey(message.id),
                    child: ChatMessageBubble(
                      message: message,
                      onRetry: message.isError ? () => _retry(state, index) : null,
                    ).entrance(context),
                  ),
                if (state.isLoading) const ThinkingDots(),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
          child: _InputBar(
            controller: _textController,
            enabled: !state.isLoading,
            onSend: _send,
          ),
        ),
      ],
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
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ask a question about your income, spending, or goals.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted, height: 1.45),
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

/// A rounded message field with a brass send button.
class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.enabled, required this.onSend});

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSend(),
            decoration: const InputDecoration(
              hintText: 'Ask about your spending',
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          tooltip: 'Send',
          onPressed: enabled ? onSend : null,
          style: IconButton.styleFrom(
            fixedSize: const Size(52, 52),
            backgroundColor: AppColors.brass,
            foregroundColor: AppColors.background,
            disabledBackgroundColor: AppColors.brassDim,
          ),
          icon: const Icon(Icons.arrow_upward_rounded),
        ),
      ],
    );
  }
}
