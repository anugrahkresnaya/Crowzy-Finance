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
import '../../../data/models/account_model.dart';
import '../../../data/models/transfer_model.dart';
import '../providers/account_provider.dart';
import '../providers/transfer_provider.dart';
import 'transfer_form_screen.dart';

/// One transfer shown as a receipt, with Edit and Delete beneath it. It
/// follows the live transfer, so changes made from Edit show here when you
/// come back. The amount is in plain ink: the money was moved, not spent.
class TransferReceiptScreen extends ConsumerWidget {
  const TransferReceiptScreen({super.key, required this.transferId});

  final String transferId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete transfer?',
      message: 'This also removes its fee entry and puts the money back.',
    );
    if (!confirmed) return;

    await ref.read(transferListProvider.notifier).deleteTransfer(transferId);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfers = ref.watch(transferListProvider).value ?? const [];
    final accounts = ref.watch(accountListProvider).value ?? const [];
    final transfer = transfers.firstWhereOrNull((t) => t.id == transferId);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfer')),
      body: transfer == null
          ? const EmptyState(
              icon: Icons.swap_horiz_rounded,
              message: 'This transfer no longer exists',
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(27, 8, 27, 24),
                children: [
                  _Receipt(transfer: transfer, accounts: accounts),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => pushSlide(
                            context,
                            TransferFormScreen(transfer: transfer),
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
  const _Receipt({required this.transfer, required this.accounts});

  final TransferModel transfer;
  final List<AccountModel> accounts;

  String _name(String id) => accounts.firstWhereOrNull((a) => a.id == id)?.name ?? 'Unknown account';

  @override
  Widget build(BuildContext context) {
    final from = _name(transfer.fromAccountId);
    final to = _name(transfer.toAccountId);
    final note = transfer.note?.isNotEmpty == true ? transfer.note! : null;
    final hasFee = transfer.fee > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ReceiptPrinterSlot(),
        ReceiptPrint(
          child: ReceiptSlip(
            tornTop: true,
            animateLines: true,
            linesDelay: const Duration(milliseconds: 650),
            children: [
              const ReceiptHeading(title: 'CROWZY FINANCE', subtitle: 'TRANSFER RECEIPT'),
              const ReceiptDivider(),
              Center(
                child: Text(
                  (note ?? 'Transfer').toUpperCase(),
                  textAlign: TextAlign.center,
                  style: ReceiptText.muted(context).copyWith(letterSpacing: 12 * 0.12),
                ),
              ),
              const SizedBox(height: 8),
              _Route(from: from, to: to),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  CurrencyFormatter.number(transfer.amount),
                  style: ReceiptText.amount(context, size: 48, color: AppColors.ink),
                ),
              ),
              Center(
                child: Text('IDR · MOVED, NOT SPENT', style: ReceiptText.muted(context)),
              ),
              const ReceiptDivider(),
              ReceiptRow(label: 'From', value: from),
              ReceiptRow(label: 'To', value: to),
              ReceiptRow(label: 'Fee', value: hasFee ? CurrencyFormatter.number(transfer.fee) : 'None'),
              ReceiptRow(label: 'Date', value: DateFormatter.receiptDate(transfer.date)),
              if (note != null) ReceiptRow(label: 'Note', value: note),
              ReceiptRow(
                label: 'Status',
                value: transfer.isSynced ? 'Synced' : 'Waiting to sync',
              ),
              const ReceiptDivider(margin: EdgeInsets.only(top: 14, bottom: 12)),
              ReceiptSummaryLine(
                label: 'LEFT ${from.toUpperCase()}',
                value: CurrencyFormatter.number(transfer.amount + transfer.fee),
              ),
              ReceiptSummaryLine(
                label: 'REACHED ${to.toUpperCase()}',
                value: CurrencyFormatter.number(transfer.amount),
              ),
              const SizedBox(height: 16),
              const ReceiptBarcode(),
              const SizedBox(height: 8),
              const ReceiptFooter('THANK YOU FOR TRACKING'),
            ],
          ),
        ),
      ],
    );
  }
}

/// "BCA → DANA" with a drawn arrow, as on the canvas.
class _Route extends StatelessWidget {
  const _Route({required this.from, required this.to});

  final String from;
  final String to;

  @override
  Widget build(BuildContext context) {
    final style = ReceiptText.mono(context, size: 15, bold: true).copyWith(letterSpacing: 1.5);

    return Semantics(
      label: 'From $from to $to',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(child: Text(from, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
          const SizedBox(width: 12),
          const SizedBox(width: 44, height: 14, child: CustomPaint(painter: _ArrowPainter())),
          const SizedBox(width: 12),
          Flexible(child: Text(to, maxLines: 1, overflow: TextOverflow.ellipsis, style: style)),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final y = size.height / 2;
    final right = size.width - 1;
    canvas.drawLine(Offset(1, y), Offset(right, y), paint);
    canvas.drawPath(
      Path()
        ..moveTo(right - 6, y - 5)
        ..lineTo(right, y)
        ..lineTo(right - 6, y + 5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => false;
}
