import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../../../data/models/alert_model.dart';
import '../../../../data/models/alert_type.dart';

({IconData icon, Color color, String title}) _alertVisuals(AlertType type) {
  return switch (type) {
    AlertType.categorySpike => (
        icon: Icons.trending_up_rounded,
        color: AppColors.expense,
        title: 'Unusual spending',
      ),
    AlertType.overspend => (
        icon: Icons.warning_amber_rounded,
        color: AppColors.expense,
        title: 'Overspending',
      ),
    AlertType.wishlistOffPace => (
        icon: Icons.flag_outlined,
        color: AppColors.brass,
        title: 'Goal off pace',
      ),
    AlertType.incomeDrop => (
        icon: Icons.trending_down_rounded,
        color: AppColors.expense,
        title: 'Income drop',
      ),
  };
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, this.onTap});

  final AlertModel alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final visuals = _alertVisuals(alert.type);
    final isUnread = alert.isUnread;
    final textTheme = Theme.of(context).textTheme;

    return PressScale(
      enabled: onTap != null,
      child: Material(
        color: isUnread ? AppColors.noticeBackground : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: isUnread ? AppColors.noticeBorder : AppColors.hairlineSoft),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnread ? AppColors.noticeIcon : AppColors.surface,
                    border: Border.all(
                      color: isUnread ? AppColors.noticeBorder : AppColors.hairline,
                    ),
                  ),
                  child: Icon(visuals.icon, color: visuals.color, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              visuals.title,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                                color: isUnread ? AppColors.ivory : AppColors.textSoft,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.expense,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.message,
                        style: textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: isUnread ? AppColors.textSoft : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormatter.ago(alert.createdAt).toUpperCase(),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          letterSpacing: 11 * 0.12,
                          color: isUnread ? AppColors.textMuted : AppColors.textFaint,
                        ),
                      ),
                    ],
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
