import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/amount_input.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../data/models/category_model.dart';

/// What the user chose in the limit dialog. A null [limit] means "remove it".
class CategoryLimitChoice {
  const CategoryLimitChoice(this.limit);

  final double? limit;
}

/// Asks for a category's optional monthly limit. Returns null when cancelled.
Future<CategoryLimitChoice?> showCategoryLimitDialog(
  BuildContext context, {
  required CategoryModel category,
  required double? currentLimit,
}) {
  return showDialog<CategoryLimitChoice>(
    context: context,
    builder: (context) => _LimitDialog(category: category, currentLimit: currentLimit),
  );
}

class _LimitDialog extends StatefulWidget {
  const _LimitDialog({required this.category, required this.currentLimit});

  final CategoryModel category;
  final double? currentLimit;

  @override
  State<_LimitDialog> createState() => _LimitDialogState();
}

class _LimitDialogState extends State<_LimitDialog> {
  late final _controller = TextEditingController(
    text: widget.currentLimit == null ? '' : CurrencyFormatter.number(widget.currentLimit!),
  );
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(CategoryLimitChoice(ThousandsInputFormatter.parse(_controller.text)));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.category.name} limit'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Optional. You will be warned as this month\'s spending nears it.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _controller,
              label: 'Monthly limit',
              hint: 'No limit',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                const ThousandsInputFormatter(),
              ],
              // Empty is fine: it means no limit.
              validator: (value) {
                if (value == null || value.trim().isEmpty) return null;
                final parsed = ThousandsInputFormatter.parse(value);
                return parsed == null || parsed <= 0 ? 'Enter an amount above zero' : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.currentLimit != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(const CategoryLimitChoice(null)),
            child: const Text('Remove limit'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(88, 44)),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
