import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/amount_input.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/wishlist_model.dart';
import '../providers/wishlist_provider.dart';

class AddEditWishlistScreen extends ConsumerStatefulWidget {
  const AddEditWishlistScreen({super.key, this.goal});

  final WishlistModel? goal;

  @override
  ConsumerState<AddEditWishlistScreen> createState() => _AddEditWishlistScreenState();
}

class _AddEditWishlistScreenState extends ConsumerState<AddEditWishlistScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.goal?.name);
  late final _targetController = TextEditingController(
    text: widget.goal == null ? '' : CurrencyFormatter.number(widget.goal!.targetAmount),
  );

  late DateTime? _deadline = widget.goal?.deadline;

  bool get _isEditing => widget.goal != null;

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final targetAmount = ThousandsInputFormatter.parse(_targetController.text)!;
    final notifier = ref.read(wishlistListProvider.notifier);
    final existing = widget.goal;

    if (existing == null) {
      await notifier.addGoal(
        name: name,
        targetAmount: targetAmount,
        deadline: _deadline,
      );
    } else {
      await notifier.updateGoal(
        existing.copyWith(
          name: name,
          targetAmount: targetAmount,
          deadline: _deadline,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<WishlistModel>>>(wishlistListProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save goal: $error')),
        ),
      );
    });

    final isLoading = ref.watch(wishlistListProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit goal' : 'New goal')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Goal name',
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _targetController,
                label: 'Target amount',
                hint: '0',
                keyboardType: TextInputType.number,
                enabled: !isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  const ThousandsInputFormatter(),
                ],
                validator: (value) {
                  final parsed = ThousandsInputFormatter.parse(value ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 18),
              Container(
                constraints: const BoxConstraints(minHeight: 56),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.hairlineSoft),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: isLoading ? null : _pickDeadline,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Deadline',
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                              ),
                              Text(
                                _deadline != null ? DateFormatter.day(_deadline!) : 'None',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: _deadline != null ? AppColors.ivory : AppColors.textFaint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_deadline != null)
                      IconButton(
                        tooltip: 'Clear deadline',
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: AppColors.textLabel,
                        onPressed: isLoading ? null : () => setState(() => _deadline = null),
                      ),
                  ],
                ),
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
              : Text(_isEditing ? 'Save changes' : 'Save goal'),
        ),
      ),
    );
  }
}
