import 'package:flutter/material.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';

Future<TransactionModel?> showCorrectionCandidatePickerSheet(
  BuildContext context,
  List<TransactionModel> candidates,
  List<CategoryModel> categories,
) {
  return showModalBottomSheet<TransactionModel>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) =>
        _CorrectionCandidatePickerSheet(candidates: candidates, categories: categories),
  );
}

class _CorrectionCandidatePickerSheet extends StatelessWidget {
  const _CorrectionCandidatePickerSheet({required this.candidates, required this.categories});

  final List<TransactionModel> candidates;
  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    final categoryById = {for (final c in categories) c.id: c};

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Which transaction did you mean?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: candidates.length,
                itemBuilder: (context, index) {
                  final transaction = candidates[index];
                  final category = categoryById[transaction.categoryId];
                  return ListTile(
                    leading: Icon(IconMapper.iconFor(category?.icon ?? 'category')),
                    title: Text(
                      '${category?.name ?? 'Uncategorized'} — ${CurrencyFormatter.format(transaction.amount)}',
                    ),
                    subtitle: Text(
                      transaction.note?.isNotEmpty == true
                          ? '${DateFormatter.day(transaction.date)} · ${transaction.note}'
                          : DateFormatter.day(transaction.date),
                    ),
                    onTap: () => Navigator.of(context).pop(transaction),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
