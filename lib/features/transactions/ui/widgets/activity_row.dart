import 'package:flutter/material.dart';

import '../../../../core/utils/app_page_route.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/transfer.dart';
import '../../../accounts/ui/transfer_receipt_screen.dart';
import '../../../accounts/ui/widgets/transfer_tile.dart';
import '../../utils/activity_feed.dart';
import '../transaction_detail_screen.dart';
import 'transaction_tile.dart';

/// One row of Activity or Home's recent list: a transaction as its tile, or a
/// transfer as its own. A transfer's fee is a transaction too, but it belongs
/// to its transfer, so tapping it opens the transfer's receipt.
class ActivityRow extends StatelessWidget {
  const ActivityRow({
    super.key,
    required this.entry,
    required this.categoryById,
    required this.accountNames,
    required this.feeTransfers,
    this.showDate = true,
    this.showAccount = false,
    this.showFeeRoute,
    this.perspectiveAccountId,
  });

  final ActivityEntry entry;
  final Map<String, CategoryModel> categoryById;

  /// Account names by id.
  final Map<String, String> accountNames;

  /// A transfer's fee expense id → its transfer, so a fee reads as part of it.
  final Map<String, Transfer> feeTransfers;

  final bool showDate;

  /// Whether a transaction's line also names its account (Activity does, Home
  /// does not).
  final bool showAccount;

  /// Whether a transfer fee's line names the transfer's route. Defaults to
  /// [showAccount].
  final bool? showFeeRoute;

  /// Set on an account's page, so its transfers read from that account's side.
  final String? perspectiveAccountId;

  String _name(String? id) => accountNames[id] ?? 'Unknown account';

  @override
  Widget build(BuildContext context) {
    switch (entry) {
      case TransferEntry(:final transfer):
        return TransferTile(
          transfer: transfer,
          fromName: _name(transfer.fromAccountId),
          toName: _name(transfer.toAccountId),
          showDate: showDate,
          perspectiveAccountId: perspectiveAccountId,
          onTap: () => pushSlide(context, TransferReceiptScreen(transferId: transfer.id)),
        );
      case TransactionEntry(:final transaction):
        final fee = feeTransfers[transaction.id];
        String? accountLabel;
        if (fee != null) {
          if (showFeeRoute ?? showAccount) {
            accountLabel = '${_name(fee.fromAccountId)} → ${_name(fee.toAccountId)}';
          }
        } else if (showAccount) {
          final id = transaction.accountId;
          if (id != null) accountLabel = accountNames[id];
        }
        return TransactionTile(
          transaction: transaction,
          category: categoryById[transaction.categoryId],
          showDate: showDate,
          accountLabel: accountLabel,
          onTap: () => pushSlide(
            context,
            fee != null
                ? TransferReceiptScreen(transferId: fee.id)
                : TransactionDetailScreen(transactionId: transaction.id),
          ),
        );
    }
  }
}
