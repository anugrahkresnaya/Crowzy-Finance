import 'package:flutter/material.dart';

import '../../../../data/models/account_type.dart';

extension AccountTypeIcon on AccountType {
  IconData get icon => switch (this) {
        AccountType.bank => Icons.account_balance_outlined,
        AccountType.ewallet => Icons.account_balance_wallet_outlined,
        AccountType.cash => Icons.payments_outlined,
      };
}
