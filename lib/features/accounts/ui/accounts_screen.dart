import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/app_page_route.dart';
import '../../../core/widgets/balance_card.dart';
import '../../../core/widgets/entrance.dart';
import '../../../core/widgets/ledger_frame.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/account_type.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/balance_provider.dart';
import '../utils/account_activity.dart';
import 'account_form_screen.dart';
import 'widgets/account_row.dart';

/// Where the user's money is held: the total across accounts, then each
/// account grouped as Bank, E-wallet and Cash.
class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showArchived = false;

  void _open(AccountModel account) {
    pushSlide(context, AccountFormScreen(account: account));
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountListProvider);
    final balances = ref.watch(accountBalanceMapProvider);
    final entries = ref.watch(accountEntriesThisMonthProvider);
    final defaultId = ref.watch(defaultAccountIdProvider);
    final total = ref.watch(allTimeBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            tooltip: 'Add account',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: AppColors.brass,
              fixedSize: const Size(44, 44),
              shape: const CircleBorder(side: BorderSide(color: AppColors.brassOutline)),
            ),
            icon: const Icon(Icons.add_rounded, size: 22),
            onPressed: () => pushSlide(context, const AccountFormScreen()),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load accounts: $error')),
        data: (all) {
          final active = all.where((a) => !a.isArchived).toList();
          final archived = all.where((a) => a.isArchived).toList();
          var rowIndex = 0;

          Widget row(AccountModel account, {bool dimmed = false}) {
            final index = rowIndex++;
            return AccountRow(
              key: ValueKey(account.id),
              account: account,
              balance: balances[account.id] ?? account.openingBalance,
              subtitle: accountSubtitle(
                isDefault: account.id == defaultId,
                entriesThisMonth: entries[account.id] ?? 0,
              ),
              dimmed: dimmed,
              onTap: () => _open(account),
            ).entrance(context, index: index, axis: Axis.horizontal);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              LedgerFrame(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACROSS ${active.length} ACCOUNT${active.length == 1 ? '' : 'S'}',
                      style: AppText.eyebrow(context),
                    ),
                    const SizedBox(height: 10),
                    BalanceAmount(balance: total, size: 44),
                  ],
                ),
              ),
              for (final type in AccountType.values)
                ...() {
                  final ofType = active.where((a) => a.type == type).toList();
                  if (ofType.isEmpty) return <Widget>[];
                  return [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 20, 2, 2),
                      child: Text(type.label.toUpperCase(), style: AppText.eyebrow(context)),
                    ),
                    for (final account in ofType) row(account),
                  ];
                }(),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.info_outline_rounded, size: 16, color: AppColors.brass),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'A transfer only moves money between your accounts. It never counts as '
                        'income or expense, apart from an optional fee.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                              height: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 8),
                Semantics(
                  button: true,
                  expanded: _showArchived,
                  child: InkWell(
                    onTap: () => setState(() => _showArchived = !_showArchived),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            '${archived.length} archived account${archived.length == 1 ? '' : 's'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textFaint),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (_showArchived) ...[for (final account in archived) row(account, dimmed: true)],
              ],
            ],
          );
        },
      ),
    );
  }
}
