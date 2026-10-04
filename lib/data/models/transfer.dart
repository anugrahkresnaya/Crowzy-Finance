/// Money moved from one account to another, as the user sees it.
///
/// There is no transfers table: a transfer is two ordinary transactions that
/// share a `transfer_group_id` (an expense on the source, an income on the
/// destination), and this is the pair put back together. The optional [fee] is
/// a separate expense, found by its derived id.
class Transfer {
  const Transfer({
    required this.id,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.fee,
    required this.date,
    required this.outLegId,
    required this.inLegId,
    required this.isSynced,
    this.note,
    this.feeId,
  });

  /// The group id shared by the two legs.
  final String id;

  /// Null when a leg has no account.
  final String? fromAccountId;
  final String? toAccountId;
  final double amount;
  final double fee;
  final DateTime date;
  final String? note;

  /// Transaction ids of the expense (source) and income (destination) legs.
  final String outLegId;
  final String inLegId;

  /// The fee expense's id when there is one.
  final String? feeId;

  /// Both legs, and the fee, have reached the server.
  final bool isSynced;
}
