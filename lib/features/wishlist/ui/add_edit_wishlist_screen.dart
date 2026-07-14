import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late final _targetController =
      TextEditingController(text: widget.goal?.targetAmount.toStringAsFixed(0));

  late DateTime? _deadline = widget.goal?.deadline;

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
    final targetAmount = double.parse(_targetController.text.trim());
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Add Goal' : 'Edit Goal'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Goal name',
                enabled: !isLoading,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _targetController,
                label: 'Target amount',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !isLoading,
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline (optional)'),
                subtitle: Text(_deadline != null ? DateFormatter.day(_deadline!) : 'None'),
                trailing: _deadline != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: isLoading ? null : () => setState(() => _deadline = null),
                      )
                    : const Icon(Icons.calendar_today_outlined),
                onTap: isLoading ? null : _pickDeadline,
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
