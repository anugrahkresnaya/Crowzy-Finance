import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils/app_page_route.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/ai_transaction_suggestion.dart';
import '../../../data/models/category_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/ui/add_edit_transaction_screen.dart';
import '../providers/ai_analyzer_provider.dart';
import 'widgets/ai_suggestion_confirm_sheet.dart';

class AiAnalyzerScreen extends ConsumerStatefulWidget {
  const AiAnalyzerScreen({super.key});

  @override
  ConsumerState<AiAnalyzerScreen> createState() => _AiAnalyzerScreenState();
}

class _AiAnalyzerScreenState extends ConsumerState<AiAnalyzerScreen> {
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

    return Scaffold(
      appBar: AppBar(title: const Text('Add with AI')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Describe a transaction in plain text and AI will fill in the details for you to confirm.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _textController,
                label: 'e.g. "spent 50k on coffee today"',
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
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
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
      ),
    );
  }
}
