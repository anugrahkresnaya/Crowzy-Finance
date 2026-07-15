import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/ai_transaction_suggestion.dart';
import '../../../../data/models/transaction_type.dart';
import '../../../categories/providers/category_provider.dart';

/// The (possibly user-edited) final fields to commit, returned by
/// [showAiSuggestionConfirmSheet]. [categoryId] is set when an existing
/// category was chosen; [newCategory] is set when a new one should be
/// created first. Exactly one of the two is non-null.
class AiConfirmResult {
  const AiConfirmResult({
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    this.categoryId,
    this.newCategory,
  });

  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;
  final String? categoryId;
  final AiProposedCategory? newCategory;
}

Future<AiConfirmResult?> showAiSuggestionConfirmSheet(
  BuildContext context,
  AiTransactionSuggestion suggestion,
) {
  return showModalBottomSheet<AiConfirmResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _AiSuggestionConfirmSheet(suggestion: suggestion),
  );
}

class _AiSuggestionConfirmSheet extends ConsumerStatefulWidget {
  const _AiSuggestionConfirmSheet({required this.suggestion});

  final AiTransactionSuggestion suggestion;

  @override
  ConsumerState<_AiSuggestionConfirmSheet> createState() =>
      _AiSuggestionConfirmSheetState();
}

class _AiSuggestionConfirmSheetState
    extends ConsumerState<_AiSuggestionConfirmSheet> {
  late final _amountController =
      TextEditingController(text: widget.suggestion.amount.toStringAsFixed(0));
  late final _noteController = TextEditingController(text: widget.suggestion.note);

  late TransactionType _type = widget.suggestion.type;
  late DateTime _date = widget.suggestion.date;
  late String? _categoryId = widget.suggestion.matchedCategoryId;
  late bool _createNewCategory =
      widget.suggestion.matchedCategoryId == null &&
          widget.suggestion.proposedNewCategory != null;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _confirm() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    if (!_createNewCategory && _categoryId == null) return;

    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      AiConfirmResult(
        amount: amount,
        type: _type,
        date: _date,
        note: note.isEmpty ? null : note,
        categoryId: _createNewCategory ? null : _categoryId,
        newCategory: _createNewCategory ? widget.suggestion.proposedNewCategory : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.income
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    if (!_createNewCategory &&
        _categoryId != null &&
        !categories.any((c) => c.id == _categoryId)) {
      _categoryId = categories.isNotEmpty ? categories.first.id : null;
    }

    final color = _type == TransactionType.income ? AppColors.income : AppColors.expense;
    final proposed = widget.suggestion.proposedNewCategory;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_outlined),
                const SizedBox(width: 8),
                Text('AI suggestion', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            if (widget.suggestion.confidence == AiConfidence.low) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Not sure about this one — please double-check the details below.",
                ),
              ),
            ],
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() {
                _type = selection.first;
                _categoryId = null;
                _createNewCategory = false;
              }),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _amountController,
              label: 'Amount',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            if (proposed != null && proposed.type == _type) ...[
              Card(
                child: SwitchListTile(
                  title: Text("New category '${proposed.name}' will be created"),
                  subtitle: const Text('Turn off to pick an existing category instead'),
                  value: _createNewCategory,
                  onChanged: (value) => setState(() => _createNewCategory = value),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!_createNewCategory)
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
              ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormatter.day(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            const SizedBox(height: 8),
            AppTextField(controller: _noteController, label: 'Note (optional)'),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: color),
                    onPressed: _confirm,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
