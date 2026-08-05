import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/alert_model.dart';
import '../../../../data/models/alert_type.dart';

(IconData, Color) _alertVisuals(AlertType type) {
  return switch (type) {
    AlertType.categorySpike => (Icons.trending_up_rounded, AppColors.expense),
    AlertType.overspend => (Icons.warning_amber_rounded, AppColors.error),
    AlertType.wishlistOffPace => (Icons.flag_outlined, AppColors.seed),
    AlertType.incomeDrop => (Icons.trending_down_rounded, AppColors.error),
  };
}

class AlertTile extends StatelessWidget {
  const AlertTile({super.key, required this.alert, this.onTap});

  final AlertModel alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, iconColor) = _alertVisuals(alert.type);
    final isUnread = alert.isUnread;

    return Opacity(
      opacity: isUnread ? 1.0 : 0.6,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.w400,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.day(alert.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isUnread)
                  Container(
                    margin: const EdgeInsets.only(top: 4, left: 8),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: AppColors.seed, shape: BoxShape.circle),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
