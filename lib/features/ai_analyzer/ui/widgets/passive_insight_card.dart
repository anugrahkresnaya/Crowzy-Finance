import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/passive_insight.dart';
import '../../providers/passive_insight_provider.dart';

/// Read-only Home-screen card surfacing an LLM-generated month-over-month
/// observation. Silently renders nothing while loading, on error, or when
/// there's no notable insight yet — this is a nice-to-have summary, not
/// critical path, so it must never make Home look broken.
class PassiveInsightCard extends ConsumerWidget {
  const PassiveInsightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insight = ref.watch(passiveInsightControllerProvider).value;
    if (insight == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final (icon, iconColor) = switch (insight.trend) {
      InsightTrend.up => (Icons.trending_up_rounded, colorScheme.error),
      InsightTrend.down => (Icons.trending_down_rounded, colorScheme.primary),
      InsightTrend.neutral => (Icons.auto_awesome_outlined, colorScheme.primary),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
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
                  insight.headline,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
