import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../../data/models/transfer.dart';

/// One transfer as a hairline-divided row. It has its own look, a brass
/// swap icon and a brass amount with no sign, because a transfer is neither
/// income nor expense.
///
/// With [showDate] (Home, sorted lists) the line beneath reads
/// "Yesterday · BCA → DANA". Inside a day group it reads "BCA → DANA ·
/// Transfer", so the row still says what it is.
class TransferTile extends StatelessWidget {
  const TransferTile({
    super.key,
    required this.transfer,
    required this.fromName,
    required this.toName,
    this.onTap,
    this.showDate = true,
    this.perspectiveAccountId,
  });

  final Transfer transfer;
  final String fromName;
  final String toName;
  final VoidCallback? onTap;
  final bool showDate;

  /// When the row is shown on one account's page, the transfer reads from
  /// that account's side: "To DANA" with a minus when it left, "From BCA"
  /// with a plus when it arrived.
  final String? perspectiveAccountId;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final note = transfer.note?.isNotEmpty == true ? transfer.note! : null;
    final perspective = perspectiveAccountId;
    final leaving = perspective != null && perspective == transfer.fromAccountId;
    final arriving = perspective != null && perspective == transfer.toAccountId && !leaving;
    final route = leaving
        ? 'To $toName'
        : arriving
            ? 'From $fromName'
            : '$fromName → $toName';
    final subtitle = [
      if (showDate) DateFormatter.relativeDay(transfer.date),
      route,
      if (!showDate && note != null) 'Transfer',
    ].join(' · ');

    return PressScale(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
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
                    color: AppColors.hero,
                    border: Border.all(color: AppColors.brassOutline),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: AppColors.brass, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note ?? 'Transfer',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${leaving ? '−' : arriving ? '+' : ''}${CurrencyFormatter.number(transfer.amount)}',
                  style: AppText.amount(context, color: AppColors.brass),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
