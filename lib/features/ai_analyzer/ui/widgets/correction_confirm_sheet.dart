import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/ai_correction_intent.dart';
import '../../../../data/models/ai_transaction_suggestion.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../../data/models/transaction_type.dart';
import '../../../categories/providers/category_provider.dart';

/// The (possibly user-edited) final fields to commit, returned by
/// [showCorrectionConfirmSheet].
class CorrectionConfirmResult {
  const CorrectionConfirmResult({
    required this.amount,
    required this.type,
    required this.date,
    this.note,
    required this.categoryId,
  });

  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? note;
  final String categoryId;
}

Future<CorrectionConfirmResult?> showCorrectionConfirmSheet(
  BuildContext context, {
  required TransactionModel matched,
  required AiCorrectionIntent intent,
}) {
  return showModalBottomSheet<CorrectionConfirmResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CorrectionConfirmSheet(matched: matched, intent: intent),
  );
}

class _CorrectionConfirmSheet extends ConsumerStatefulWidget {
  const _CorrectionConfirmSheet({required this.matched, required this.intent});

  final TransactionModel matched;
  final AiCorrectionIntent intent;

  @override
  ConsumerState<_CorrectionConfirmSheet> createState() => _CorrectionConfirmSheetState();
}

class _CorrectionConfirmSheetState extends ConsumerState<_CorrectionConfirmSheet> {
  late final _amountController = TextEditingController(
    text: (widget.intent.newAmount ?? widget.matched.amount).toStringAsFixed(0),
  );
  late final _noteController =
      TextEditingController(text: widget.intent.newNote ?? widget.matched.note);

  late TransactionType _type = widget.matched.type;
  late DateTime _date = widget.intent.newDate ?? widget.matched.date;
  late String? _categoryId = _resolveNewCategoryId() ?? widget.matched.categoryId;

  String? _resolveNewCategoryId() {
    final hint = widget.intent.newCategoryHint?.toLowerCase();
    if (hint == null) return null;
    final categories = ref.read(categoryListProvider).value ?? const [];
    for (final c in categories) {
      if (c.type == _type && c.name.toLowerCase().contains(hint)) return c.id;
    }
    return null;
  }

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
    if (_categoryId == null) return;

    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      CorrectionConfirmResult(
        amount: amount,
        type: _type,
        date: _date,
        note: note.isEmpty ? null : note,
        categoryId: _categoryId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == TransactionType.income
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = categories.isNotEmpty ? categories.first.id : null;
    }

    final color = _type == TransactionType.income ? AppColors.income : AppColors.expense;

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
                Text('Confirm correction', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            if (widget.intent.confidence == AiConfidence.low) ...[
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
              }),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _amountController,
              label: 'Amount',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            if (widget.intent.newAmount != null && widget.intent.newAmount != widget.matched.amount) ...[
              const SizedBox(height: 4),
              _WasCaption('Was: ${CurrencyFormatter.format(widget.matched.amount)}'),
            ],
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
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
            if (widget.intent.newDate != null &&
                !DateFormatter.isSameDay(widget.intent.newDate!, widget.matched.date)) ...[
              const SizedBox(height: 4),
              _WasCaption('Was: ${DateFormatter.day(widget.matched.date)}'),
            ],
            const SizedBox(height: 8),
            AppTextField(controller: _noteController, label: 'Note (optional)'),
            if (widget.intent.newNote != null && widget.intent.newNote != widget.matched.note) ...[
              const SizedBox(height: 4),
              _WasCaption('Was: ${widget.matched.note?.isNotEmpty == true ? widget.matched.note : '(none)'}'),
            ],
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
                    child: const Text('Confirm'),
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

class _WasCaption extends StatelessWidget {
  const _WasCaption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
