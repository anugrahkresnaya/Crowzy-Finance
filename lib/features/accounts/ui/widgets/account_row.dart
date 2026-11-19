import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/account_model.dart';
import 'account_icon.dart';

/// One account on the Accounts screen: icon, name, a line about its activity
/// and its balance in serif figures.
class AccountRow extends StatelessWidget {
  const AccountRow({
    super.key,
    required this.account,
    required this.balance,
    required this.subtitle,
    required this.onTap,
    this.dimmed = false,
    this.icon,
  });

  final AccountModel account;
  final double balance;
  final String subtitle;
  final VoidCallback onTap;

  /// Archived accounts are shown quieter.
  final bool dimmed;

  /// Replaces the account type's icon, for the row that stands for no account.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final negative = balance < 0;
    final figure = '${negative ? '−' : ''}${CurrencyFormatter.number(balance.abs())}';

    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(2, 14, 2, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Icon(icon ?? account.type.icon, size: 19, color: AppColors.brass),
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
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  figure,
                  style: AppText.amount(
                    context,
                    size: 21,
                    color: negative ? AppColors.expense : AppColors.ivory,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
