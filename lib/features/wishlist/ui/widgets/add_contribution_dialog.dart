import 'package:flutter/material.dart';

import '../../../../data/models/wishlist_model.dart';

Future<double?> showAddContributionDialog(BuildContext context, WishlistModel goal) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add to "${goal.name}"'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount to add'),
          validator: (value) {
            final parsed = double.tryParse(value?.trim() ?? '');
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
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            Navigator.of(context).pop(double.parse(controller.text.trim()));
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
