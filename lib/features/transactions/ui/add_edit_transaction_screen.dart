import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/amount_input.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/press_scale.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../ai_analyzer/ui/ai_analyzer_screen.dart';
import '../../categories/providers/category_provider.dart';
import '../../categories/ui/add_edit_category_screen.dart';
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
  late final _amountController = TextEditingController(
    text: widget.transaction == null ? '' : CurrencyFormatter.number(widget.transaction!.amount),
  );
  late final _noteController = TextEditingController(text: widget.transaction?.note);

  late TransactionType _type = widget.transaction?.type ?? TransactionType.expense;
  late DateTime _date = widget.transaction?.date ?? DateTime.now();
  late String? _categoryId = widget.transaction?.categoryId;
  bool _categoryInitialized = false;

  bool get _isEditing => widget.transaction != null;

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

    final amount = ThousandsInputFormatter.parse(_amountController.text)!;
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

    // Wait for the categories before choosing one: while they are still
    // loading the list is empty, and acting on it would wipe the selection.
    if (categories.isNotEmpty) {
      if (!_categoryInitialized && widget.transaction == null) {
        final lastUsed = ref.read(lastUsedCategoryIdProvider(_type));
        _categoryId = categories.any((c) => c.id == lastUsed) ? lastUsed : categories.first.id;
        _categoryInitialized = true;
      }
      if (_categoryId != null && !categories.any((c) => c.id == _categoryId)) {
        _categoryId = categories.first.id;
      }
    }

    final isLoading = ref.watch(transactionListProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit transaction' : 'New transaction'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            children: [
              SegmentedButton<TransactionType>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                  ButtonSegment(value: TransactionType.income, label: Text('Income')),
                ],
                selected: {_type},
                onSelectionChanged: isLoading
                    ? null
                    : (selection) => setState(() {
                          _type = selection.first;
                          _categoryInitialized = false;
                        }),
              ),
              const SizedBox(height: 28),
              Center(child: Text('AMOUNT', style: AppText.eyebrow(context))),
              const SizedBox(height: 8),
              _AmountField(controller: _amountController, enabled: !isLoading),
              const SizedBox(height: 26),
              Text('CATEGORY', style: AppText.eyebrow(context)),
              const SizedBox(height: 10),
              _CategoryGrid(
                categories: categories,
                selectedId: _categoryId,
                enabled: !isLoading,
                onSelected: (id) => setState(() => _categoryId = id),
                onAdd: () => pushSlide(context, AddEditCategoryScreen(initialType: _type)),
              ),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.hairlineSoft),
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      onTap: isLoading ? null : _pickDate,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 56),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.divider)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date',
                              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                            ),
                            Text(DateFormatter.relativeDayWithDate(_date), style: textTheme.bodyLarge),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Note',
                            style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _noteController,
                              enabled: !isLoading,
                              textAlign: TextAlign.end,
                              style: textTheme.bodyLarge,
                              decoration: InputDecoration(
                                hintText: 'Optional',
                                hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textFaint),
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => pushSlide(context, const AiAnalyzerScreen(initialMode: AiMode.add)),
                    icon: const Icon(Icons.auto_awesome_outlined, size: 16),
                    label: const Text('Describe it in words instead'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(22, 8, 22, 16),
        child: FilledButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save changes' : 'Save transaction'),
        ),
      ),
    );
  }
}

/// Large serif amount with a brass underline. The "Rp" sits beside the figure.
class _AmountField extends StatelessWidget {
  const _AmountField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final figure = AppText.amount(context, size: 56, color: AppColors.ivory);
    const none = InputBorder.none;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('Rp', style: AppText.amount(context, size: 24, color: AppColors.brass)),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 56),
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  textAlign: TextAlign.center,
                  style: figure,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    const ThousandsInputFormatter(),
                  ],
                  validator: (value) {
                    final parsed = ThousandsInputFormatter.parse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: figure.copyWith(color: AppColors.textFaint),
                    isDense: true,
                    filled: false,
                    border: none,
                    enabledBorder: none,
                    focusedBorder: none,
                    disabledBorder: none,
                    errorBorder: none,
                    focusedErrorBorder: none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 40), color: AppColors.brassOutline),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.enabled,
    required this.onSelected,
    required this.onAdd,
  });

  final List<CategoryModel> categories;
  final String? selectedId;
  final bool enabled;
  final ValueChanged<String> onSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.95,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final category in categories)
          _CategoryTile(
            icon: IconMapper.iconFor(category.icon),
            label: category.name,
            selected: category.id == selectedId,
            onTap: enabled ? () => onSelected(category.id) : null,
          ),
        _CategoryTile(
          icon: Icons.add_rounded,
          label: 'New',
          dashed: true,
          onTap: enabled ? onAdd : null,
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.label,
    this.selected = false,
    this.dashed = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool dashed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.brass : AppColors.textLabel;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: PressScale(
        enabled: onTap != null,
        child: Material(
          color: selected ? AppColors.hero : (dashed ? Colors.transparent : AppColors.surface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: selected ? AppColors.brass : (dashed ? AppColors.textFaint : AppColors.hairline),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
