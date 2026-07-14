import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/transaction_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({super.key, this.transaction});

  final TransactionModel? transaction;

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController =
      TextEditingController(text: widget.transaction?.amount.toStringAsFixed(0));
  late final _noteController = TextEditingController(text: widget.transaction?.note);

  late TransactionType _type = widget.transaction?.type ?? TransactionType.expense;
  late DateTime _date = widget.transaction?.date ?? DateTime.now();
  late String? _categoryId = widget.transaction?.categoryId;
  bool _categoryInitialized = false;

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;

    final amount = double.parse(_amountController.text.trim());
    final note = _noteController.text.trim();
    final notifier = ref.read(transactionListProvider.notifier);
    final existing = widget.transaction;

    if (existing == null) {
      await notifier.addTransaction(
        amount: amount,
        type: _type,
        categoryId: _categoryId!,
        date: _date,
        note: note.isEmpty ? null : note,
      );
    } else {
      await notifier.updateTransaction(
        existing.copyWith(
          amount: amount,
          type: _type,
          categoryId: _categoryId!,
          date: _date,
          note: note.isEmpty ? null : note,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<TransactionModel>>>(transactionListProvider,
        (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transaction: $error')),
        ),
      );
    });

    final categories = _type == TransactionType.income
        ? ref.watch(incomeCategoriesProvider)
        : ref.watch(expenseCategoriesProvider);

    if (!_categoryInitialized && widget.transaction == null) {
      final lastUsed = ref.read(lastUsedCategoryIdProvider(_type));
      if (categories.any((c) => c.id == lastUsed)) {
        _categoryId = lastUsed;
      } else if (categories.isNotEmpty) {
        _categoryId = categories.first.id;
      }
      _categoryInitialized = true;
    }
    if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
      _categoryId = categories.isNotEmpty ? categories.first.id : null;
    }

    final isLoading = ref.watch(transactionListProvider).isLoading;
    final color = _type == TransactionType.income ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(value: TransactionType.income, label: Text('Income')),
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                ],
                selected: {_type},
                onSelectionChanged: isLoading
                    ? null
                    : (selection) => setState(() {
                          _type = selection.first;
                          _categoryInitialized = false;
                        }),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _amountController,
                label: 'Amount',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !isLoading,
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: isLoading ? null : (value) => setState(() => _categoryId = value),
                validator: (value) => value == null ? 'Select a category' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(DateFormatter.day(_date)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: isLoading ? null : _pickDate,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _noteController,
                label: 'Note (optional)',
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: color),
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
