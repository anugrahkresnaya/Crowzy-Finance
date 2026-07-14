import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../categories/providers/category_provider.dart';
import '../../../transactions/ui/widgets/transaction_tile.dart';
import '../../providers/report_provider.dart';

class ReportListView extends ConsumerWidget {
  const ReportListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(monthTransactionsProvider);
    final categories = ref.watch(categoryListProvider).value ?? const [];
    final categoryById = {for (final c in categories) c.id: c};

    if (transactions.isEmpty) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No transactions this month',
      );
    }

    final sorted = [...transactions]..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final transaction = sorted[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TransactionTile(
            transaction: transaction,
            category: categoryById[transaction.categoryId],
          ),
        );
      },
    );
  }
}
