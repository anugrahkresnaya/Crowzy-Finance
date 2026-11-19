import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/press_scale.dart';
import '../../utils/greeting.dart';

const _logOut = 'log_out';

/// Top of Home: the user's monogram (tap for the account menu), today's date
/// and a greeting, and a bell that opens the alerts.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.name,
    required this.unreadAlerts,
    required this.onOpenAlerts,
    required this.onSignOut,
    this.now,
  });

  final String? name;
  final int unreadAlerts;
  final VoidCallback onOpenAlerts;
  final VoidCallback onSignOut;

  /// Overridable clock, for tests.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final current = now ?? DateTime.now();
    final greeting = name == null ? greetingFor(current) : '${greetingFor(current)}, $name';
    final date = '${DateFormatter.weekday(current)}, ${DateFormatter.dayLong(current)}';

    return Row(
      children: [
        PopupMenuButton<String>(
          tooltip: 'Account menu',
          offset: const Offset(0, 52),
          onSelected: (value) {
            if (value == _logOut) onSignOut();
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(value: _logOut, child: Text('Log out')),
          ],
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brassOutline),
            ),
            child: Text(
              (name ?? '?')[0].toUpperCase(),
              style: AppText.amount(context, size: 22, color: AppColors.brass),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date.toUpperCase(), style: AppText.eyebrow(context, color: AppColors.textMuted)),
              const SizedBox(height: 1),
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _BellButton(unread: unreadAlerts, onTap: onOpenAlerts),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.unread, required this.onTap});

  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: unread > 0 ? 'Alerts, $unread new' : 'Alerts',
      excludeSemantics: true,
      onTap: onTap,
      child: PressScale(
        pressedScale: 0.92,
        child: Material(
          color: AppColors.surface,
          shape: const CircleBorder(side: BorderSide(color: AppColors.hairline)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_none_rounded, size: 20, color: AppColors.ivory),
                  if (unread > 0)
                    Positioned(
                      top: 10,
                      right: 11,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.expense,
                          shape: BoxShape.circle,
                        ),
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
