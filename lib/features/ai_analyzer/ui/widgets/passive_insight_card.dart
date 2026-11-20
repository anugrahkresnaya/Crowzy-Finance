import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../providers/passive_insight_provider.dart';

/// Read-only card surfacing an LLM-generated month-over-month observation.
/// Silently renders nothing while loading, on error, or when there's no
/// notable insight yet — this is a nice-to-have summary, not critical path, so
/// it must never make its screen look broken.
class PassiveInsightCard extends ConsumerWidget {
  const PassiveInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(passiveInsightControllerProvider).value;
    if (insight == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.hero,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.heroBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('INSIGHT', style: AppText.eyebrow(context, color: AppColors.brass)),
          const SizedBox(height: 6),
          Text(
            insight.headline,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 4),
          Text(
            insight.detail,
            style: textTheme.bodySmall?.copyWith(color: AppColors.textLabel, height: 1.45),
          ),
        ],
      ),
    );
  }
}
