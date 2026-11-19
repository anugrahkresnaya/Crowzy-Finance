import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/confirm_dialog.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/receipt_slip.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/transaction_type.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_edit_transaction_screen.dart';

/// One transaction shown as a receipt, with Edit and Delete beneath it. It
/// follows the live transaction, so changes made from Edit show here when you
/// come back.
class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete transaction?',
      message: 'This cannot be undone.',
    );
    if (!confirmed) return;

    await ref.read(transactionListProvider.notifier).deleteTransaction(transactionId);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider).value ?? const [];
    final categories = ref.watch(categoryListProvider).value ?? const [];
    final transaction = transactions.firstWhereOrNull((t) => t.id == transactionId);
    final category = categories.firstWhereOrNull((c) => c.id == transaction?.categoryId);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: transaction == null
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              message: 'This transaction no longer exists',
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(27, 8, 27, 24),
                children: [
                  _Receipt(transaction: transaction, category: category),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => pushSlide(
                            context,
                            AddEditTransactionScreen(transaction: transaction),
                          ),
                          child: const Text('Edit'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.expense,
                            backgroundColor: AppColors.noticeBackground,
                            side: const BorderSide(color: AppColors.noticeBorder),
                          ),
                          onPressed: () => _delete(context, ref),
                          child: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _Receipt extends StatelessWidget {
  const _Receipt({required this.transaction, required this.category});

  final TransactionModel transaction;
  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final categoryName = category?.name ?? 'Uncategorized';
    final note = transaction.note?.isNotEmpty == true ? transaction.note! : null;
    final amountColor = isIncome ? AppColors.inkIncome : AppColors.oxblood;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PrinterSlot(),
        ReceiptPrint(child: _slip(context, isIncome, categoryName, note, amountColor)),
      ],
    );
  }

  Widget _slip(
    BuildContext context,
    bool isIncome,
    String categoryName,
    String? note,
    Color amountColor,
  ) {
    return ReceiptSlip(
      tornTop: true,
      animateLines: true,
      linesDelay: const Duration(milliseconds: 650),
      children: [
        const ReceiptHeading(title: 'CROWZY FINANCE', subtitle: 'TRANSACTION RECEIPT'),
        const ReceiptDivider(),
        Center(
          child: Text(
            (note ?? categoryName).toUpperCase(),
            textAlign: TextAlign.center,
            style: ReceiptText.muted(context).copyWith(letterSpacing: 12 * 0.12),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            CurrencyFormatter.signed(transaction.amount, income: isIncome),
            style: ReceiptText.amount(context, size: 48, color: amountColor),
          ),
        ),
        Center(
          child: Text(
            'IDR · ${isIncome ? 'INCOME' : 'EXPENSE'}',
            style: ReceiptText.muted(context),
          ),
        ),
        const ReceiptDivider(),
        ReceiptRow(label: 'Category', value: categoryName),
        ReceiptRow(label: 'Date', value: DateFormatter.receiptDate(transaction.date)),
        ReceiptRow(
          label: 'Status',
          value: transaction.isSynced ? 'Synced' : 'Waiting to sync',
        ),
        const ReceiptDivider(margin: EdgeInsets.only(top: 14, bottom: 12)),
        ReceiptTotal(
          label: 'TOTAL',
          amount: CurrencyFormatter.signed(transaction.amount, income: isIncome),
          color: amountColor,
        ),
        const SizedBox(height: 16),
        const ReceiptBarcode(),
        const SizedBox(height: 8),
        const ReceiptFooter('THANK YOU FOR TRACKING'),
      ],
    );
  }
}

/// The dark slot the receipt appears to feed out of.
class _PrinterSlot extends StatelessWidget {
  const _PrinterSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.slot,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.hairline),
      ),
    );
  }
}
