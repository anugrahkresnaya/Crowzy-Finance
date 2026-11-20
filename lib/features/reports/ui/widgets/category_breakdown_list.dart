import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_progress_bar.dart';
import '../../repository/report_repository.dart';

/// Category totals with their share of the month. Tap a row to see how many
/// transactions it covers and their average.
class CategoryBreakdownList extends StatefulWidget {
  const CategoryBreakdownList({super.key, required this.entries});

  final List<CategoryBreakdownEntry> entries;

  @override
  State<CategoryBreakdownList> createState() => _CategoryBreakdownListState();
}

class _CategoryBreakdownListState extends State<CategoryBreakdownList> {
  int? _open;

  @override
  void didUpdateWidget(CategoryBreakdownList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final open = _open;
    if (open != null && open >= widget.entries.length) _open = null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        for (final (index, entry) in widget.entries.indexed)
          Semantics(
            button: true,
            expanded: _open == index,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => setState(() => _open = _open == index ? null : index),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.divider)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(entry.category?.name ?? 'Uncategorized', style: textTheme.bodyMedium),
                          Text.rich(
                            TextSpan(
                              text: CurrencyFormatter.number(entry.total),
                              style: AppText.amount(context, size: 17),
                              children: [
                                TextSpan(
                                  text: '  ·  ${entry.percentage.round()}%',
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      AppProgressBar(
                        value: entry.percentage / 100,
                        color: _open == index ? AppColors.ivory : AppColors.brass,
                        semanticLabel: entry.category?.name ?? 'Uncategorized',
                      ),
                      AnimatedSize(
                        duration: AppMotion.scaled(context, AppMotion.base),
                        curve: AppMotion.curveOut,
                        alignment: Alignment.topCenter,
                        child: _open == index
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _detail(entry),
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _detail(CategoryBreakdownEntry entry) {
    final noun = entry.count == 1 ? 'transaction' : 'transactions';
    final average = entry.count == 0 ? 0 : entry.total / entry.count;
    return '${entry.count} $noun · average ${CurrencyFormatter.format(average)}';
  }
}
