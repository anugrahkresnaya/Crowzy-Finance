import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../data/models/alert_model.dart';
import '../providers/alert_provider.dart';
import 'widgets/alert_tile.dart';

class AlertsListScreen extends ConsumerWidget {
  const AlertsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertListProvider);

    ref.listen<AsyncValue<List<AlertModel>>>(alertListProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$error')),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Failed to load alerts: $error')),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_outlined,
              message: 'No alerts yet — we\'ll let you know if something needs attention',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AlertTile(
                  alert: alert,
                  onTap: alert.isUnread
                      ? () => ref.read(alertListProvider.notifier).markRead(alert.id)
                      : null,
                ).animate().fadeIn(delay: (40 * index).ms, duration: 250.ms).slideX(
                      begin: 0.03,
                      end: 0,
                    ),
              );
            },
          );
        },
      ),
    );
  }
}
