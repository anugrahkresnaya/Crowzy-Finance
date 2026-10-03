import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/app_page_route.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../providers/alert_provider.dart';
import '../alerts_list_screen.dart';

/// Home-screen notice for unread spending/income alerts. Silently renders
/// nothing when there are no unread alerts — this is a nice-to-have summary,
/// not critical path, so it must never make Home look broken.
class AlertsCard extends ConsumerWidget {
  const AlertsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadAlertsProvider);
    if (unread.isEmpty) return const SizedBox.shrink();

    final latest = unread.first;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: PressScale(
        child: Material(
          color: AppColors.noticeBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.noticeBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => pushSlide(context, const AlertsListScreen()),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('NOTICE', style: AppText.eyebrow(context, color: AppColors.expense)),
                  const SizedBox(height: 6),
                  Text(
                    latest.message,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, height: 1.35),
                  ),
                  if (unread.length > 1) ...[
                    const SizedBox(height: 6),
                    Text(
                      '+${unread.length - 1} more alert${unread.length > 2 ? 's' : ''}',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
