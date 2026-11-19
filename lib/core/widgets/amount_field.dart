import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../utils/amount_input.dart';

/// A large serif amount with a brass underline and a brass "Rp" beside it,
/// grouping thousands as you type. Used for transactions, transfers and
/// account balances.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.size = 56,
    this.centered = true,
    this.allowZero = false,
    this.underlineInset = 40,
  });

  final TextEditingController controller;
  final bool enabled;

  /// Font size of the figure; the "Rp" scales with it.
  final double size;

  /// Centred (transactions, transfers) or left-aligned (account balance).
  final bool centered;

  /// Whether an empty field or zero is acceptable.
  final bool allowZero;

  /// Gap between the underline and each edge.
  final double underlineInset;

  @override
  Widget build(BuildContext context) {
    final figure = AppText.amount(context, size: size, color: AppColors.ivory);
    const none = InputBorder.none;

    return Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Rp',
              style: AppText.amount(context, size: size >= 56 ? 24 : 22, color: AppColors.brass),
            ),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: size),
                child: TextFormField(
                  controller: controller,
                  enabled: enabled,
                  textAlign: centered ? TextAlign.center : TextAlign.start,
                  style: figure,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    const ThousandsInputFormatter(),
                  ],
                  validator: (value) {
                    final parsed = ThousandsInputFormatter.parse(value ?? '');
                    if (allowZero) {
                      if (value == null || value.trim().isEmpty) return null;
                      return parsed == null ? 'Enter a valid amount' : null;
                    }
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: figure.copyWith(color: AppColors.textFaint),
                    isDense: true,
                    filled: false,
                    border: none,
                    enabledBorder: none,
                    focusedBorder: none,
                    disabledBorder: none,
                    errorBorder: none,
                    focusedErrorBorder: none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          height: 1,
          margin: EdgeInsets.symmetric(horizontal: underlineInset),
          color: AppColors.brassOutline,
        ),
      ],
    );
  }
}
