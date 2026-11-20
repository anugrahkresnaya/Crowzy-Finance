import 'package:crowzy_finance/core/constants/default_categories.dart';
import 'package:crowzy_finance/data/models/transaction_model.dart';
import 'package:crowzy_finance/data/models/transaction_type.dart';
import 'package:crowzy_finance/features/accounts/utils/transfers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/transfers.dart';

void main() {
  // Rows shaped like the ones the live server holds: two legs, the same
  // timestamp and note, an expense in Transfer Out and an income in Transfer In.
  final topUp = fakeTransfer('g1', from: 'bca', to: 'dana', amount: 390000, note: 'topup');

  List<TransactionModel> only(TransactionModel t) => [t];

  group('deriveTransfers', () {
    test('puts an expense and an income leg of one group back together as a transfer', () {
      final transfers = deriveTransfers(legsOf(topUp));

      expect(transfers, hasLength(1));
      final t = transfers.single;
      expect(t.id, 'g1');
      expect(t.fromAccountId, 'bca');
      expect(t.toAccountId, 'dana');
      expect(t.amount, 390000);
      expect(t.note, 'topup');
      expect(t.outLegId, 'g1-out');
      expect(t.inLegId, 'g1-in');
      expect(t.fee, 0);
      expect(t.feeId, isNull);
    });

    test('the order of the two legs does not matter', () {
      expect(deriveTransfers(legsOf(topUp).reversed), hasLength(1));
    });

    test('finds the fee by its derived id, as an ordinary expense', () {
      final withFee = fakeTransfer('g1', fee: 2500);
      final transfers = deriveTransfers([...legsOf(withFee), feeOf(withFee)]);

      expect(transfers.single.fee, 2500);
      expect(transfers.single.feeId, feeIdFor('g1'));
    });

    test('an expense that merely looks like a fee is not one', () {
      final other = feeOf(fakeTransfer('someone-else', fee: 99));

      expect(deriveTransfers([...legsOf(topUp), other]).single.fee, 0);
    });

    test('is synced only when both legs and the fee are', () {
      final synced = fakeTransfer('g1', fee: 100);
      expect(deriveTransfers([...legsOf(synced), feeOf(synced)]).single.isSynced, isTrue);

      final pending = deriveTransfers([
        ...legsOf(synced),
        feeOf(synced).copyWith(isSynced: false),
      ]);
      expect(pending.single.isSynced, isFalse);

      final legPending = legsOf(synced);
      legPending[1] = legPending[1].copyWith(isSynced: false);
      expect(deriveTransfers(legPending).single.isSynced, isFalse);
    });

    test('a leg whose partner is missing is not a transfer', () {
      expect(deriveTransfers(only(legsOf(topUp).first)), isEmpty);
      expect(deriveTransfers(only(legsOf(topUp).last)), isEmpty);
    });

    test('a group with the wrong legs is left alone rather than breaking the list', () {
      final legs = legsOf(topUp);
      final twoOuts = [legs.first, legs.first.copyWith(id: 'another-out')];
      expect(deriveTransfers(twoOuts), isEmpty);

      final extra = [...legs, legs.first.copyWith(id: 'third-leg')];
      expect(deriveTransfers(extra), isEmpty);
    });

    test('legs in the wrong categories are not a transfer', () {
      final legs = legsOf(topUp)
          .map((t) => t.copyWith(categoryId: '00000000-0000-4000-8000-000000000005'))
          .toList();

      expect(deriveTransfers(legs), isEmpty);
    });

    test('ordinary transactions are ignored', () {
      final plain = TransactionModel(
        id: 'p',
        userId: 'u1',
        amount: 5,
        type: TransactionType.expense,
        categoryId: 'food',
        date: DateTime(2026, 10, 2),
        createdAt: DateTime(2026, 10, 2),
        updatedAt: DateTime(2026, 10, 2),
      );

      expect(deriveTransfers([plain]), isEmpty);
    });

    test('uses the note of either leg, and none when neither has one', () {
      final legs = legsOf(topUp);
      final onlyIn = [legs.first.copyWith(note: null), legs.last];
      expect(deriveTransfers(onlyIn).single.note, 'topup');

      final blank = [legs.first.copyWith(note: ''), legs.last.copyWith(note: '')];
      expect(deriveTransfers(blank).single.note, isNull);
    });

    test('a leg with no account gives a transfer with no account on that side', () {
      final legs = legsOf(topUp);
      final transfers = deriveTransfers([legs.first.copyWith(accountId: null), legs.last]);

      expect(transfers.single.fromAccountId, isNull);
      expect(transfers.single.toAccountId, 'dana');
    });

    test('lists newest first', () {
      final older = fakeTransfer('old', date: DateTime(2026, 9, 1));
      final newer = fakeTransfer('new', date: DateTime(2026, 10, 1));

      expect(
        deriveTransfers([...legsOf(older), ...legsOf(newer)]).map((t) => t.id),
        ['new', 'old'],
      );
    });

    test('two transfers do not mix their legs', () {
      final a = fakeTransfer('a', from: 'bca', to: 'dana', amount: 1);
      final b = fakeTransfer('b', from: 'cash', to: 'bca', amount: 2);
      final transfers = deriveTransfers([...legsOf(a), ...legsOf(b)]);

      final byId = {for (final t in transfers) t.id: t};
      expect(byId['a']!.toAccountId, 'dana');
      expect(byId['b']!.fromAccountId, 'cash');
      expect(byId['b']!.amount, 2);
    });
  });

  group('isTransferLeg', () {
    TransactionModel tx({String? group, String category = 'food'}) => TransactionModel(
          id: 'x',
          userId: 'u',
          amount: 1,
          type: TransactionType.expense,
          categoryId: category,
          transferGroupId: group,
          date: DateTime(2026),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );

    test('a transaction in a group is a leg', () => expect(isTransferLeg(tx(group: 'g')), isTrue));

    test('a transaction in a transfer category is a leg even without a group', () {
      expect(isTransferLeg(tx(category: DefaultCategories.transferOutId)), isTrue);
      expect(isTransferLeg(tx(category: DefaultCategories.transferInId)), isTrue);
    });

    test('an ordinary transaction, and a transfer fee, are not', () {
      expect(isTransferLeg(tx()), isFalse);
      expect(isTransferLeg(feeOf(fakeTransfer('g', fee: 100))), isFalse);
    });
  });

  group('feeIdFor and the helpers', () {
    test('the fee id is stable per group and differs between groups', () {
      expect(feeIdFor('g1'), feeIdFor('g1'));
      expect(feeIdFor('g1'), isNot(feeIdFor('g2')));
      expect(feeIdFor('g1'), isNot('g1'));
      expect(
        feeIdFor('g1'),
        matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
      );
    });

    test('legIdsOf lists both legs of every transfer', () {
      expect(
        legIdsOf([fakeTransfer('a'), fakeTransfer('b')]),
        {'a-out', 'a-in', 'b-out', 'b-in'},
      );
    });

    test('feesByTransfer maps a fee expense to its transfer, and skips transfers without one', () {
      final withFee = fakeTransfer('a', fee: 50);
      final map = feesByTransfer([withFee, fakeTransfer('b')]);

      expect(map.keys, [feeIdFor('a')]);
      expect(map[feeIdFor('a')], same(withFee));
    });
  });
}
