import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/amount_input.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/receipt_slip.dart';
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

/// Shows what the assistant read as a draft slip to check. Returns the final
/// fields when the user adds it, or null when they cancel.
Future<AiConfirmResult?> showAiSuggestionConfirmSheet(
  BuildContext context,
  AiTransactionSuggestion suggestion,
) {
  return showModalBottomSheet<AiConfirmResult>(
    context: context,
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
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
      TextEditingController(text: CurrencyFormatter.number(widget.suggestion.amount));
  late final _noteController = TextEditingController(text: widget.suggestion.note);

  late TransactionType _type = widget.suggestion.type;
  late DateTime _date = widget.suggestion.date;
  late String? _categoryId = widget.suggestion.matchedCategoryId;
  late bool _createNewCategory =
      widget.suggestion.matchedCategoryId == null &&
          widget.suggestion.proposedNewCategory != null;

  bool _editing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double? get _amount => ThousandsInputFormatter.parse(_amountController.text);

  bool get _canConfirm {
    final amount = _amount;
    if (amount == null || amount <= 0) return false;
    return _createNewCategory || _categoryId != null;
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

  /// Adds it if everything needed is there; otherwise opens the form so the
  /// missing piece can be filled in.
  void _add() {
    if (!_canConfirm) {
      setState(() => _editing = true);
      return;
    }

    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      AiConfirmResult(
        amount: _amount!,
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
    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(27, 0, 27, 20),
          child: _editing ? _form(context) : _slip(context),
        ),
      ),
    );
  }

  // ---- the draft slip

  String _categoryLabel() {
    if (_createNewCategory) {
      return '${widget.suggestion.proposedNewCategory?.name ?? 'New category'} (new)';
    }
    final categories = ref.watch(categoryListProvider).value ?? const [];
    return categories.firstWhereOrNull((c) => c.id == _categoryId)?.name ?? 'Choose one';
  }

  Widget _slip(BuildContext context) {
    final isIncome = _type == TransactionType.income;
    final note = _noteController.text.trim();
    final categoryLabel = _categoryLabel();
    final amount = _amount ?? 0;
    final amountColor = isIncome ? AppColors.inkIncome : AppColors.oxblood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReceiptSlip(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const ReceiptHeading(title: 'DRAFT SLIP', subtitle: 'READ FROM YOUR MESSAGE'),
                const Positioned(right: -6, top: 28, child: ReceiptStamp(text: 'DRAFT')),
              ],
            ),
            const ReceiptDivider(margin: EdgeInsets.only(top: 14, bottom: 8)),
            ReceiptRow(label: 'Item', value: note.isEmpty ? categoryLabel : note, bold: true),
            ReceiptRow(label: 'Category', value: categoryLabel, bold: true),
            ReceiptRow(label: 'Type', value: isIncome ? 'Income' : 'Expense', bold: true),
            ReceiptRow(label: 'Date', value: DateFormatter.receiptDate(_date), bold: true),
            const ReceiptDivider(margin: EdgeInsets.symmetric(vertical: 10)),
            ReceiptTotal(
              label: 'AMOUNT',
              amount: CurrencyFormatter.signed(amount, income: isIncome),
              color: amountColor,
            ),
            const SizedBox(height: 6),
            if (widget.suggestion.confidence == AiConfidence.low)
              Text(
                'Not sure about this one — please double-check the details.',
                style: ReceiptText.muted(context, size: 11).copyWith(fontStyle: FontStyle.italic),
              )
            else
              Text(
                'Use Edit details to correct anything before adding it.',
                style: ReceiptText.muted(context, size: 11).copyWith(fontStyle: FontStyle.italic),
              ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton(onPressed: _add, child: const Text('Add transaction')),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () => setState(() => _editing = true),
                child: const Text('Edit details'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---- the form

  Widget _form(BuildContext context) {
    final categories = _type == TransactionType.income
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    if (!_createNewCategory &&
        _categoryId != null &&
        categories.isNotEmpty &&
        !categories.any((c) => c.id == _categoryId)) {
      _categoryId = categories.first.id;
    }

    final proposed = widget.suggestion.proposedNewCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<TransactionType>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
            ButtonSegment(value: TransactionType.income, label: Text('Income')),
          ],
          selected: {_type},
          onSelectionChanged: (selection) => setState(() {
            _type = selection.first;
            _categoryId = null;
            _createNewCategory = false;
          }),
        ),
        const SizedBox(height: 18),
        AppTextField(
          controller: _amountController,
          label: 'Amount',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            const ThousandsInputFormatter(),
          ],
        ),
        const SizedBox(height: 18),
        if (proposed != null && proposed.type == _type) ...[
          Card(
            child: SwitchListTile(
              title: Text("New category '${proposed.name}' will be created"),
              subtitle: const Text('Turn off to pick an existing category instead'),
              value: _createNewCategory,
              onChanged: (value) => setState(() => _createNewCategory = value),
            ),
          ),
          const SizedBox(height: 18),
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
        const SizedBox(height: 18),
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
        FilledButton(onPressed: _add, child: const Text('Add transaction')),
        const SizedBox(height: 10),
        OutlinedButton(
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: () => setState(() => _editing = false),
          child: const Text('Back to the slip'),
        ),
      ],
    );
  }
}
