import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/amount_input.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/wishlist_model.dart';

/// Asks how much to add to [goal]. Returns the amount, or null if cancelled.
Future<double?> showAddContributionDialog(BuildContext context, WishlistModel goal) {
  return showDialog<double>(
    context: context,
    builder: (context) => _ContributionDialog(goal: goal),
  );
}

class _ContributionDialog extends StatefulWidget {
  const _ContributionDialog({required this.goal});

  final WishlistModel goal;

  @override
  State<_ContributionDialog> createState() => _ContributionDialogState();
}

class _ContributionDialogState extends State<_ContributionDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(ThousandsInputFormatter.parse(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add to "${widget.goal.name}"'),
      content: Form(
        key: _formKey,
        child: AppTextField(
          controller: _controller,
          label: 'Amount to add',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
