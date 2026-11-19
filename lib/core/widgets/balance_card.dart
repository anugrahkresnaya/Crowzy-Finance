import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../utils/currency_formatter.dart';
import 'ledger_frame.dart';

/// Hero card at the top of Home: the all-time balance in large serif figures,
/// with this month's income and expenses beneath. It is framed by a brass
/// outline with a second hairline inside, like a ledger plate.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
    this.changePercent,
    this.accountsSummary,
    this.onManageAccounts,
  });

  final num balance;
  final num monthIncome;
  final num monthExpense;

  /// This month's change in balance; hidden when null.
  final double? changePercent;

  /// A line such as "3 accounts · BCA, DANA, Cash" under the figures, with a
  /// Manage link to the accounts screen. Hidden when null.
  final String? accountsSummary;
  final VoidCallback? onManageAccounts;

  @override
  Widget build(BuildContext context) {
    final change = changePercent;

    return LedgerFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            container: true,
            label:
                'Total balance ${CurrencyFormatter.format(balance)}. '
                'Income this month ${CurrencyFormatter.format(monthIncome)}. '
                'Expenses this month ${CurrencyFormatter.format(monthExpense)}.',
            child: ExcludeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOTAL BALANCE', style: AppText.eyebrow(context)),
                      if (change != null)
                        Text(
                          '${CurrencyFormatter.signedPercent(change)} this month',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: change >= 0
                                    ? AppColors.income
                                    : AppColors.expense,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BalanceAmount(balance: balance),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.heroBorder, height: 1),
                  const SizedBox(height: 14),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _Figure(
                            label: 'INCOME',
                            text: CurrencyFormatter.signed(
                              monthIncome,
                              income: true,
                            ),
                            color: AppColors.income,
                          ),
                        ),
                        const VerticalDivider(
                          color: AppColors.heroBorder,
                          width: 1,
                          thickness: 1,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18),
                            child: _Figure(
                              label: 'EXPENSES',
                              text: CurrencyFormatter.signed(
                                monthExpense,
                                income: false,
                              ),
                              color: AppColors.expense,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (accountsSummary != null)
            _AccountsStrip(
              summary: accountsSummary!,
              onManage: onManageAccounts,
            ),
        ],
      ),
    );
  }
}

class _AccountsStrip extends StatelessWidget {
  const _AccountsStrip({required this.summary, required this.onManage});

  final String summary;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.heroBorder)),
        ),
        child: Semantics(
          button: true,
          label: 'Manage accounts. $summary',
          excludeSemantics: true,
          child: InkWell(
            onTap: onManage,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textLabel,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Manage ›',
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.brass,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The balance in serif figures with a brass "Rp", counting up from zero.
class BalanceAmount extends StatelessWidget {
  const BalanceAmount({super.key, required this.balance, this.size = 50});

  final num balance;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: balance.toDouble()),
      duration: AppMotion.scaled(context, AppMotion.countUp),
      curve: AppMotion.curveOut,
      builder: (context, value, _) {
        final negative = value < 0;
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp',
                style: AppText.amount(
                  context,
                  size: 20,
                  color: AppColors.brass,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${negative ? '−' : ''}${CurrencyFormatter.number(value.abs())}',
                style: AppText.amount(
                  context,
                  size: size,
                  color: AppColors.ivory,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.text, required this.color});

  final String label;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.eyebrow(context)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: AppText.amount(context, size: 21, color: color),
          ),
        ),
      ],
    );
  }
}
