import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/press_scale.dart';

enum AddChoice { expense, income, transfer }

/// The sheet behind the centre + button: what kind of entry is being added.
/// Returns the choice, or null if it is dismissed.
Future<AddChoice?> showAddChooserSheet(BuildContext context) {
  return showModalBottomSheet<AddChoice>(
    context: context,
    sheetAnimationStyle: AppMotion.sheetAnimation(context),
    builder: (context) => const _AddChooserSheet(),
  );
}

class _AddChooserSheet extends StatelessWidget {
  const _AddChooserSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ADD', style: AppText.eyebrow(context)),
            const SizedBox(height: 2),
            Text('What happened?', style: AppText.amount(context, size: 28)),
            const SizedBox(height: 14),
            _Option(
              choice: AddChoice.expense,
              title: 'Expense',
              caption: 'Money you spent',
              icon: Icons.arrow_downward_rounded,
              iconColor: AppColors.expense,
              iconBackground: AppColors.noticeBackground,
              iconBorder: AppColors.noticeBorder,
            ),
            const SizedBox(height: 10),
            _Option(
              choice: AddChoice.income,
              title: 'Income',
              caption: 'Money you received',
              icon: Icons.arrow_upward_rounded,
              iconColor: AppColors.income,
              iconBackground: AppColors.hero,
              iconBorder: AppColors.heroBorder,
            ),
            const SizedBox(height: 10),
            _Option(
              choice: AddChoice.transfer,
              title: 'Transfer',
              caption: 'Move money between your accounts',
              icon: Icons.swap_horiz_rounded,
              iconColor: AppColors.brass,
              iconBackground: AppColors.background,
              iconBorder: AppColors.brassOutline,
              emphasised: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.choice,
    required this.title,
    required this.caption,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.iconBorder,
    this.emphasised = false,
  });

  final AddChoice choice;
  final String title;
  final String caption;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final Color iconBorder;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      child: PressScale(
        child: Material(
          color: emphasised ? AppColors.hero : AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: emphasised ? AppColors.brassOutline : AppColors.hairlineSoft),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            onTap: () => Navigator.of(context).pop(choice),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconBackground,
                      border: Border.all(color: iconBorder),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          caption,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: AppColors.textMuted,
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
      ),
    );
  }
}
