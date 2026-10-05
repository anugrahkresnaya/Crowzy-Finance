import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/amount_input.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/form_card.dart';
import '../../../core/widgets/press_scale.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/providers/balance_provider.dart';
import '../../accounts/ui/widgets/account_picker_sheet.dart';
import '../../ai_analyzer/ui/ai_analyzer_screen.dart';
import '../../categories/providers/category_provider.dart';
import '../../categories/ui/add_edit_category_screen.dart';
import '../providers/transaction_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({
    super.key,
    this.transaction,
    this.initialType = TransactionType.expense,
    this.initialAccountId,
  });

  final TransactionModel? transaction;

  /// Which side is chosen when adding a new transaction.
  final TransactionType initialType;

  /// The account chosen when adding a new transaction, e.g. from that account's page.
  final String? initialAccountId;

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

  late TransactionType _type = widget.transaction?.type ?? widget.initialType;
  late DateTime _date = widget.transaction?.date ?? DateTime.now();
  late String? _categoryId = widget.transaction?.categoryId;
  late String? _accountId = widget.transaction?.accountId ?? widget.initialAccountId;
  bool _accountInitialized = false;
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

  Future<void> _pickAccount(List<AccountModel> accounts, List<AccountModel> active) async {
    // An archived account stays pickable while editing a transaction on it.
    final current = accounts.where((a) => a.id == _accountId && a.isArchived);
    final chosen = await showAccountPickerSheet(
      context,
      accounts: [...active, ...current],
      balances: ref.read(accountBalanceMapProvider),
      selectedId: _accountId,
    );
    if (chosen != null) setState(() => _accountId = chosen.id);
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
        accountId: _accountId,
      );
    } else {
      await notifier.updateTransaction(
        existing.copyWith(
          amount: amount,
          type: _type,
          categoryId: _categoryId!,
          date: _date,
          note: note.isEmpty ? null : note,
          accountId: _accountId,
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

    final accounts = ref.watch(accountListProvider).value ?? const <AccountModel>[];
    final active = accounts.where((a) => !a.isArchived).toList();

    // As with the category, wait for the accounts before choosing one. A new
    // transaction starts on the main account, else the one last used, else the
    // first; an existing one keeps its own, which may be none.
    if (accounts.isNotEmpty && !_accountInitialized) {
      _accountInitialized = true;
      if (!_isEditing && (_accountId == null || !active.any((a) => a.id == _accountId))) {
        _accountId = ref.read(startingAccountIdProvider);
      }
    }
    final account = accounts.where((a) => a.id == _accountId).firstOrNull;

    final isLoading = ref.watch(transactionListProvider).isLoading;
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
              AmountField(controller: _amountController, enabled: !isLoading),
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
              FormCard(
                rows: [
                  FormCardRow.value(
                    label: 'Account',
                    value: account?.name ?? 'None',
                    showChevron: true,
                    onTap: isLoading || accounts.isEmpty
                        ? null
                        : () => _pickAccount(accounts, active),
                  ),
                  FormCardRow.value(
                    label: 'Date',
                    value: DateFormatter.relativeDayWithDate(_date),
                    onTap: isLoading ? null : _pickDate,
                  ),
                  FormCardRow.field(
                    label: 'Note',
                    controller: _noteController,
                    hint: 'Optional',
                    enabled: !isLoading,
                  ),
                ],
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
