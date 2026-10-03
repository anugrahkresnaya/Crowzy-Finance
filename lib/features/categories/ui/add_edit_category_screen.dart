import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
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
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit category' : 'New category')),
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
                    : (selection) => setState(() => _type = selection.first),
              ),
              const SizedBox(height: 22),
              AppTextField(
                controller: _nameController,
                label: 'Name',
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 22),
              Text('ICON', style: AppText.eyebrow(context)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in IconMapper.keys)
                    _IconChoice(
                      icon: IconMapper.iconFor(key),
                      label: key.replaceAll('_', ' '),
                      selected: key == _icon,
                      onTap: isLoading ? null : () => setState(() => _icon = key),
                    ),
                ],
              ),
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
              : Text(isEditing ? 'Save changes' : 'Save category'),
        ),
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? AppColors.hero : AppColors.surface,
        shape: CircleBorder(side: BorderSide(color: selected ? AppColors.brass : AppColors.hairline)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: selected ? AppColors.brass : AppColors.textLabel),
          ),
        ),
      ),
    );
  }
}
