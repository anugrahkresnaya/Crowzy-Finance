import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';
import '../../../transactions/ui/widgets/transaction_tile.dart';

Future<TransactionModel?> showCorrectionCandidatePickerSheet(
  BuildContext context,
  List<TransactionModel> candidates,
  List<CategoryModel> categories,
) {
  return showModalBottomSheet<TransactionModel>(
    context: context,
    sheetAnimationStyle: AppMotion.sheetAnimation(context),
    isScrollControlled: true,
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
                                  return TransactionTile(
                    transaction: transaction,
                    category: categoryById[transaction.categoryId],
                    onTap: () => Navigator.of(context).pop(transaction),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
