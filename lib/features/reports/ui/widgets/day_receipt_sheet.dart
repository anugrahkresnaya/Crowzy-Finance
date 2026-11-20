import 'package:flutter/material.dart';

import '../../../../core/theme/app_motion.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/receipt_slip.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transaction_model.dart';
import 'day_detail_card.dart';

/// Shows one day's spending as a receipt in a bottom sheet. [onViewInActivity]
/// runs after the sheet closes.
Future<void> showDayReceiptSheet(
  BuildContext context, {
  required DateTime date,
  required List<TransactionModel> expenses,
  required Map<String, CategoryModel> categoryById,
  required double average,
  required VoidCallback onViewInActivity,
}) {
  return showModalBottomSheet<void>(
    context: context,
    sheetAnimationStyle: AppMotion.sheetAnimation(context),
    isScrollControlled: true,
    showDragHandle: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
    builder: (sheetContext) => DayReceiptSheet(
      date: date,
      expenses: expenses,
      categoryById: categoryById,
      average: average,
      onViewInActivity: () {
        Navigator.of(sheetContext).pop();
        onViewInActivity();
      },
      onClose: () => Navigator.of(sheetContext).pop(),
    ),
  );
}

class DayReceiptSheet extends StatelessWidget {
  const DayReceiptSheet({
    super.key,
    required this.date,
    required this.expenses,
    required this.categoryById,
    required this.average,
    required this.onViewInActivity,
    required this.onClose,
  });

  final DateTime date;
  final List<TransactionModel> expenses;
  final Map<String, CategoryModel> categoryById;

  /// The month's average daily spending, for the "× your daily average" note.
  final double average;
  final VoidCallback onViewInActivity;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    // Most recent first, the way a till prints them.
    final lines = [...expenses]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final total = lines.fold(0.0, (sum, t) => sum + t.amount);
    final count = lines.length;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(27, 0, 27, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReceiptPrint(
              style: ReceiptPrintStyle.reveal,
              delay: AppMotion.slipRevealDelay,
              child: ReceiptSlip(
                animateLines: true,
                linesDelay: const Duration(milliseconds: 750),
                children: [
                  ReceiptHeading(
                    title: 'DAILY RECEIPT',
                    subtitle: DateFormatter.receiptDateLong(date).toUpperCase(),
                  ),
                  const ReceiptDivider(margin: EdgeInsets.only(top: 14, bottom: 10)),
                  for (final t in lines)
                    ReceiptLine(
                      title: _title(t),
                      caption: '${DateFormatter.time(t.createdAt)} · '
                          '${(categoryById[t.categoryId]?.name ?? 'Uncategorized').toUpperCase()}',
                      amount: CurrencyFormatter.signed(t.amount, income: false),
                    ),
                  const ReceiptDivider(margin: EdgeInsets.only(top: 12, bottom: 10)),
                  ReceiptTotal(
                    label: 'TOTAL · $count ${count == 1 ? 'ITEM' : 'ITEMS'}',
                    amount: CurrencyFormatter.signed(total, income: false),
                    note: DayDetailCard.multiplierText(total, average).toUpperCase(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onViewInActivity,
                    child: const Text('View in Activity'),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 96,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
                    onPressed: onClose,
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _title(TransactionModel t) {
    final note = t.note;
    if (note != null && note.isNotEmpty) return note;
    return categoryById[t.categoryId]?.name ?? 'Uncategorized';
  }
}
