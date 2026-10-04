import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../../data/models/account_model.dart';
import 'account_icon.dart';

/// Lets the user choose one of [accounts]. Returns the chosen account, or null
/// if the sheet is dismissed. [balances] supplies the figure under each name.
Future<AccountModel?> showAccountPickerSheet(
  BuildContext context, {
  required List<AccountModel> accounts,
  required Map<String, double> balances,
  String? selectedId,
}) {
  return showModalBottomSheet<AccountModel>(
    context: context,
    sheetAnimationStyle: AppMotion.sheetAnimation(context),
    isScrollControlled: true,
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
    builder: (context) => _AccountPickerSheet(
      accounts: accounts,
      balances: balances,
      selectedId: selectedId,
    ),
  );
}

class _AccountPickerSheet extends StatelessWidget {
  const _AccountPickerSheet({
    required this.accounts,
    required this.balances,
    required this.selectedId,
  });

  final List<AccountModel> accounts;
  final Map<String, double> balances;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ACCOUNT', style: AppText.eyebrow(context)),
            const SizedBox(height: 2),
            Text('Choose an account', style: AppText.amount(context, size: 28)),
            const SizedBox(height: 14),
            for (final account in accounts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AccountOption(
                  account: account,
                  balance: balances[account.id] ?? account.openingBalance,
                  selected: account.id == selectedId,
                  onTap: () => Navigator.of(context).pop(account),
                ),
              ),
            if (accounts.isEmpty)
              Text(
                'No accounts yet.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  const _AccountOption({
    required this.account,
    required this.balance,
    required this.selected,
    required this.onTap,
  });

  final AccountModel account;
  final double balance;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final negative = balance < 0;

    return Semantics(
      button: true,
      selected: selected,
      child: PressScale(
        child: Material(
          color: selected ? AppColors.hero : AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: selected ? AppColors.brassOutline : AppColors.hairlineSoft),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Icon(account.type.icon, size: 20, color: AppColors.brass),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Balance ${negative ? '−' : ''}${CurrencyFormatter.number(balance.abs())}',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: negative ? AppColors.expense : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    const Icon(Icons.check_rounded, size: 22, color: AppColors.brass),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
