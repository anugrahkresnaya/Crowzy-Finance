import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/balance_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/ledger_frame.dart';
import '../../../data/models/account_model.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/providers/activity_provider.dart';
import '../../transactions/ui/add_edit_transaction_screen.dart';
import '../../transactions/ui/widgets/activity_day_header.dart';
import '../../transactions/ui/widgets/activity_row.dart';
import '../../transactions/utils/activity_feed.dart';
import '../providers/account_provider.dart';
import '../providers/balance_provider.dart';
import '../providers/transfer_provider.dart';
import '../utils/account_balance.dart';
import '../utils/account_feed.dart';
import 'account_form_screen.dart';
import 'transfer_form_screen.dart';

/// One account: its balance, buttons to move money or add a transaction on it,
/// and what happened on it this month. Transfers read from this account's
/// side and, being transfers, are left out of the day totals.
class AccountDetailScreen extends ConsumerStatefulWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  /// Two side-by-side buttons in the balance card: compact so that
  /// "Add transaction" stays on one line.
  static final _buttonStyle = OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(44),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );

  bool _transfersOnly = false;

  @override
  Widget build(BuildContext context) {
    final accounts =
        ref.watch(accountListProvider).value ?? const <AccountModel>[];
    // Money on no account has a page too, to see what is in it. It has no
    // account to edit and nothing to transfer from.
    final isUnassigned = widget.accountId == unassignedAccountId;
    final account = accounts.firstWhereOrNull((a) => a.id == widget.accountId);
    final textTheme = Theme.of(context).textTheme;

    if (account == null && !isUnassigned) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.account_balance_wallet_outlined,
          message: 'This account no longer exists',
        ),
      );
    }

    final balance =
        ref.watch(accountBalanceMapProvider)[widget.accountId] ??
        account?.initialBalance ??
        0;
    final categories = ref.watch(categoryListProvider).value ?? const [];
    final categoryById = {for (final c in categories) c.id: c};
    final accountNames = {for (final a in accounts) a.id: a.name};
    final feeTransfers = ref.watch(feeTransfersProvider);

    final month = DateTime.now();
    final mine = filterActivity(
      entriesForAccount(
        ref.watch(activityEntriesProvider),
        accountId: widget.accountId,
      ),
      month: month,
      filter: _transfersOnly ? ActivityFilter.transfers : ActivityFilter.all,
    );
    final days = groupActivityByDay(mine);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              (account?.type.label ?? 'No account').toUpperCase(),
              style: AppText.eyebrow(context),
            ),
            Text(
              account?.name ?? 'Unassigned',
              style: textTheme.titleLarge?.copyWith(fontSize: 30, height: 1.05),
            ),
          ],
        ),
        actions: [
          if (account != null)
            IconButton(
              tooltip: 'Edit account',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.ivory,
                fixedSize: const Size(44, 44),
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.hairline),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 19),
              onPressed: () =>
                  pushSlide(context, AccountFormScreen(account: account)),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          LedgerFrame(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BALANCE', style: AppText.eyebrow(context)),
                const SizedBox(height: 8),
                BalanceAmount(balance: balance, size: 44),
                if (account != null) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: _buttonStyle,
                          onPressed: () => pushSlide(
                            context,
                            TransferFormScreen(
                              initialFromAccountId: account.id,
                            ),
                          ),
                          icon: const Icon(Icons.swap_vert_rounded, size: 17),
                          label: const Text('Transfer'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: _buttonStyle.copyWith(
                            foregroundColor: const WidgetStatePropertyAll(
                              AppColors.ivory,
                            ),
                            side: const WidgetStatePropertyAll(
                              BorderSide(color: AppColors.heroBorder),
                            ),
                          ),
                          onPressed: () => pushSlide(
                            context,
                            AddEditTransactionScreen(
                              initialAccountId: account.id,
                            ),
                          ),
                          child: const Text('Add transaction'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormatter.monthYear(month).toUpperCase(),
                    style: AppText.eyebrow(context),
                  ),
                ),
                _FilterChip(
                  label: 'All',
                  selected: !_transfersOnly,
                  onTap: () => setState(() => _transfersOnly = false),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Transfers',
                  selected: _transfersOnly,
                  onTap: () => setState(() => _transfersOnly = true),
                ),
              ],
            ),
          ),
          if (days.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                message: _transfersOnly
                    ? 'No transfers this month'
                    : 'No activity this month',
              ),
            )
          else ...[
            for (final day in days) ...[
              ActivityDayHeader(day: day),
              for (final entry in day.entries)
                ActivityRow(
                  key: ValueKey(entry.id),
                  entry: entry,
                  categoryById: categoryById,
                  accountNames: accountNames,
                  feeTransfers: feeTransfers,
                  showDate: false,
                  showFeeRoute: true,
                  perspectiveAccountId: widget.accountId,
                ).entrance(context, axis: Axis.horizontal),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 12, 2, 0),
              child: Text(
                'Transfers move money, so day totals leave them out.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textFaint,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      visualDensity: VisualDensity.compact,
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
    );
  }
}
