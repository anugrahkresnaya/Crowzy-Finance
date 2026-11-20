/// What a transfer would do to the two accounts, worked out while the form is
/// still being filled in.
class TransferPreview {
  const TransferPreview({
    required this.fromAfter,
    required this.toAfter,
    required this.sameAccount,
    required this.insufficient,
  });

  /// Source balance once the amount and fee have left it; null with no source.
  final double? fromAfter;

  /// Destination balance once the amount has arrived; null with no destination.
  final double? toAfter;

  /// Both ends are the same account, which cannot be saved.
  final bool sameAccount;

  /// The source cannot cover the amount plus fee. Only a warning: balances can
  /// be out of date, so saving is still allowed.
  final bool insufficient;
}

/// [fromBalance] and [toBalance] are the balances before this transfer (for an
/// edit, without the transfer itself), or null when that side is not chosen.
TransferPreview previewTransfer({
  required double? fromBalance,
  required double? toBalance,
  required double amount,
  required double fee,
  required bool sameAccount,
}) {
  final fromAfter = fromBalance == null ? null : fromBalance - amount - fee;
  final toAfter = toBalance == null ? null : toBalance + amount;
  return TransferPreview(
    fromAfter: fromAfter,
    toAfter: toAfter,
    sameAccount: sameAccount,
    insufficient: !sameAccount && amount > 0 && fromAfter != null && fromAfter < 0,
  );
}
