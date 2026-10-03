import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// "‹ OCTOBER 2026 ›". Pass null for [onNext] to disable the forward arrow,
/// e.g. when the current month is showing.
class MonthSwitcher extends StatelessWidget {
  const MonthSwitcher({
    super.key,
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.brass,
          onPressed: onPrevious,
        ),
        Text(label.toUpperCase(), style: AppText.eyebrow(context)),
        IconButton(
          tooltip: 'Next month',
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.brass,
          disabledColor: AppColors.brassDim,
          onPressed: onNext,
        ),
      ],
    );
  }
}
