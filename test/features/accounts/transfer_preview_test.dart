import 'package:crowzy_finance/features/accounts/utils/transfer_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransferPreview preview({
    double? from = 9730000,
    double? to = 1850000,
    double amount = 500000,
    double fee = 2500,
    bool same = false,
  }) =>
      previewTransfer(
        fromBalance: from,
        toBalance: to,
        amount: amount,
        fee: fee,
        sameAccount: same,
      );

  test('the source loses the amount and the fee, the destination gains the amount', () {
    final result = preview();

    expect(result.fromAfter, 9227500);
    expect(result.toAfter, 2350000);
    expect(result.sameAccount, isFalse);
    expect(result.insufficient, isFalse);
  });

  test('a source that cannot cover the amount plus fee is flagged', () {
    final result = preview(from: 1850000, amount: 2000000);

    expect(result.fromAfter, -152500);
    expect(result.insufficient, isTrue);
  });

  test('the fee alone can tip it over', () {
    expect(preview(from: 500000, amount: 500000, fee: 0).insufficient, isFalse);
    expect(preview(from: 500000, amount: 500000, fee: 1).insufficient, isTrue);
  });

  test('nothing is flagged before an amount is entered', () {
    expect(preview(from: -100, amount: 0, fee: 0).insufficient, isFalse);
  });

  test('the same account is its own problem, not an insufficiency', () {
    final result = preview(same: true, from: 10, amount: 500);

    expect(result.sameAccount, isTrue);
    expect(result.insufficient, isFalse);
  });

  test('a side that is not chosen has no figures', () {
    final result = preview(to: null);

    expect(result.toAfter, isNull);
    expect(result.fromAfter, 9227500);
    expect(preview(from: null).fromAfter, isNull);
    expect(preview(from: null).insufficient, isFalse);
  });
}
