import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The green plate behind the balance on Home, Accounts and an account's page:
/// a brass outline with a second hairline inside, like a ledger.
class LedgerFrame extends StatelessWidget {
  const LedgerFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 22, 20, 20),
  });

  final Widget child;

  /// Space between the inner hairline and [child].
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.hero,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.brassOutline),
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: AppColors.heroBorder),
        ),
        child: child,
      ),
    );
  }
}
