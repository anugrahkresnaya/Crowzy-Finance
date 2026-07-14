import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/category_provider.dart';

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  const AddEditCategoryScreen({
    super.key,
    this.category,
    this.initialType = TransactionType.expense,
  });

  final CategoryModel? category;
  final TransactionType initialType;

  @override
  ConsumerState<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.category?.name);
  late TransactionType _type = widget.category?.type ?? widget.initialType;
  late String _icon = widget.category?.icon ?? IconMapper.keys.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(categoryListProvider.notifier);
    final existing = widget.category;

    if (existing == null) {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId == null) return;
      await notifier.addCustomCategory(
        userId: userId,
        name: _nameController.text.trim(),
        icon: _icon,
        type: _type,
      );
    } else {
      await notifier.updateCustomCategory(
        existing.copyWith(name: _nameController.text.trim(), icon: _icon, type: _type),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<CategoryModel>>>(categoryListProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save category: $error')),
        ),
      );
    });

    final isLoading = ref.watch(categoryListProvider).isLoading;
    final color = _type == TransactionType.income ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Add Category' : 'Edit Category'),
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
                    : (selection) => setState(() => _type = selection.first),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                label: 'Name',
                enabled: !isLoading,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              Text('Icon', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IconMapper.keys.map((key) {
                  final selected = key == _icon;
                  return InkWell(
                    onTap: isLoading ? null : () => setState(() => _icon = key),
                    borderRadius: BorderRadius.circular(24),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: selected ? color.withValues(alpha: 0.2) : null,
                      child: Icon(
                        IconMapper.iconFor(key),
                        color: selected ? color : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
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
