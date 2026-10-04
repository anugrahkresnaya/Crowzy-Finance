import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// A rounded card of label-and-value rows, used for the secondary fields of a
/// form (date, note, account, fee). Rows are separated by hairlines.
class FormCard extends StatelessWidget {
  const FormCard({super.key, required this.rows});

  final List<FormCardRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.hairlineSoft),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Column(
          children: [
            for (final (index, row) in rows.indexed) row._build(context, last: index == rows.length - 1),
          ],
        ),
      ),
    );
  }
}

/// One row of a [FormCard]: a muted label on the left and a value or a text
/// field on the right.
class FormCardRow {
  /// A row that shows [value] and opens something when tapped, e.g. a picker.
  const FormCardRow.value({
    required this.label,
    required String this.value,
    this.onTap,
    this.showChevron = false,
  })  : controller = null,
        hint = null,
        enabled = true,
        keyboardType = null,
        inputFormatters = null;

  /// A row with an inline text field, right-aligned.
  const FormCardRow.field({
    required this.label,
    required TextEditingController this.controller,
    this.hint,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
  })  : value = null,
        onTap = null,
        showChevron = false;

  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool showChevron;
  final TextEditingController? controller;
  final String? hint;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  Widget _build(BuildContext context, {required bool last}) {
    final textTheme = Theme.of(context).textTheme;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(label, style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            const SizedBox(width: 16),
            Expanded(
              child: controller != null
                  ? TextField(
                      controller: controller,
                      enabled: enabled,
                      keyboardType: keyboardType,
                      inputFormatters: inputFormatters,
                      textAlign: TextAlign.end,
                      style: textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: textTheme.bodyLarge?.copyWith(color: AppColors.textFaint),
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            value!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyLarge,
                          ),
                        ),
                        if (showChevron) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.brass),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );

    final row = onTap == null ? content : InkWell(onTap: onTap, child: content);
    if (last) return row;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: row,
    );
  }
}
