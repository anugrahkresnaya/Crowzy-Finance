import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/ai_transaction_suggestion.dart';
import '../../../data/models/category_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../accounts/providers/account_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/ui/add_edit_transaction_screen.dart';
import '../providers/ai_analyzer_provider.dart';
import 'widgets/ai_suggestion_confirm_sheet.dart';
import 'widgets/chat_qa_tab.dart';

enum AiMode { ask, add }

/// The assistant: ask questions about your money, or describe a transaction
/// and let it fill in the details. Shown as a tab, or pushed (for example from
/// the new-transaction form) straight into [initialMode].
class AiAnalyzerScreen extends StatefulWidget {
  const AiAnalyzerScreen({super.key, this.initialMode = AiMode.ask});

  final AiMode initialMode;

  @override
  State<AiAnalyzerScreen> createState() => _AiAnalyzerScreenState();
}

class _AiAnalyzerScreenState extends State<AiAnalyzerScreen> {
  late AiMode _mode = widget.initialMode;

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(canGoBack ? 6 : 22, 12, 22, 0),
              child: Row(
                children: [
                  if (canGoBack)
                    IconButton(
                      tooltip: 'Back',
                      icon: const Icon(Icons.chevron_left_rounded, size: 28),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  const Icon(Icons.auto_awesome_outlined, size: 22, color: AppColors.brass),
                  const SizedBox(width: 10),
                  Text(
                    _mode == AiMode.ask ? 'Ask' : 'Add',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 32),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
              child: SegmentedButton<AiMode>(
                showSelectedIcon: false,
                expandedInsets: EdgeInsets.zero,
                segments: const [
                  ButtonSegment(value: AiMode.ask, label: Text('Ask')),
                  ButtonSegment(value: AiMode.add, label: Text('Add')),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) => setState(() => _mode = selection.first),
              ),
            ),
            // Both stay alive so a half-written message or a conversation
            // survives switching between them.
            Expanded(
              child: IndexedStack(
                index: _mode.index,
                children: const [ChatQaTab(), _AddTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTab extends ConsumerStatefulWidget {
  const _AddTab();

  @override
  ConsumerState<_AddTab> createState() => _AddTabState();
}

class _AddTabState extends ConsumerState<_AddTab> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    FocusScope.of(context).unfocus();
    await ref.read(transactionParserProvider.notifier).parse(text);
  }

  Future<void> _onSuggestion(AiTransactionSuggestion suggestion) async {
    final result = await showAiSuggestionConfirmSheet(context, suggestion);
    ref.read(transactionParserProvider.notifier).reset();
    if (result == null || !mounted) return;

    String? categoryId = result.categoryId;

    if (categoryId == null && result.newCategory != null) {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) return;
      final newCategory = result.newCategory!;
      final id = const Uuid().v4();
      final now = DateTime.now();
      await ref.read(categoryRepositoryProvider).save(
            CategoryModel(
              id: id,
              userId: userId,
              name: newCategory.name,
              icon: newCategory.icon,
              type: newCategory.type,
              createdAt: now,
              updatedAt: now,
              isSynced: false,
            ),
          );
      ref.invalidate(categoryListProvider);
      categoryId = id;
    }

    if (categoryId == null) return;

    await ref.read(transactionListProvider.notifier).addTransaction(
          amount: result.amount,
          type: result.type,
          categoryId: categoryId,
          date: result.date,
          note: result.note,
          accountId: ref.read(startingAccountIdProvider),
        );

    if (!mounted) return;
    _textController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AiTransactionSuggestion?>>(transactionParserProvider,
        (previous, next) {
      next.whenOrNull(
        data: (suggestion) {
          if (suggestion != null) _onSuggestion(suggestion);
        },
      );
    });

    final parserState = ref.watch(transactionParserProvider);
    final isLoading = parserState.isLoading;
    final error = parserState.hasError ? parserState.error : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Describe a transaction in plain text and AI will fill in the details for you to confirm.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted, height: 1.45),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _textController,
              label: 'Transaction',
              hint: 'e.g. "spent 50k on coffee today"',
              minLines: 2,
              maxLines: 4,
              enabled: !isLoading,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Parse'),
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              Text(
                '$error',
                style: const TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () =>
                    pushSlide(context, const AddEditTransactionScreen()),
                child: const Text('Add manually instead'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
