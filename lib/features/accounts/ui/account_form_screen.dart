import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/amount_input.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/account_type.dart';
import '../providers/account_provider.dart';
import '../providers/balance_provider.dart';

/// Adds an account, or edits [account]. An empty form is a new account: its
/// opening balance is what it holds right now. An existing account also offers
/// to archive itself (except the default Cash account).
class AccountFormScreen extends ConsumerStatefulWidget {
  const AccountFormScreen({super.key, this.account});

  final AccountModel? account;

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.account?.name);
  late final _balanceController = TextEditingController(
    text: widget.account == null || widget.account!.openingBalance == 0
        ? ''
        : CurrencyFormatter.number(widget.account!.openingBalance),
  );

  late AccountType _type = widget.account?.type ?? AccountType.bank;
  late bool _archived = widget.account?.isArchived ?? false;

  bool get _isEditing => widget.account != null;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final opening = ThousandsInputFormatter.parse(_balanceController.text) ?? 0;
    final notifier = ref.read(accountListProvider.notifier);
    final existing = widget.account;

    if (existing == null) {
      await notifier.addAccount(name: name, type: _type, openingBalance: opening);
    } else {
      await notifier.updateAccount(
        existing.copyWith(
          name: name,
          type: _type,
          openingBalance: opening,
          isArchived: _archived,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<AccountModel>>>(accountListProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save account: $error')),
        ),
      );
    });

    final existing = widget.account;
    final isDefault = existing != null && existing.id == ref.watch(defaultAccountIdProvider);
    final current = existing == null ? null : ref.watch(accountBalanceMapProvider)[existing.id];
    final textTheme = Theme.of(context).textTheme;

    final balanceNote = existing == null
        ? 'What this account holds right now. From here on its balance moves with every '
            'transaction and transfer.'
        : 'What this account held when you started tracking it. Its current balance, '
            '${CurrencyFormatter.number(current ?? existing.openingBalance)}, is worked out '
            'from this plus everything since.';

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit account' : 'New account')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 24),
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Name',
                hint: _isEditing ? null : 'e.g. Jago, GoPay, Wallet',
                textInputAction: TextInputAction.done,
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 22),
              Text('TYPE', style: AppText.eyebrow(context)),
              const SizedBox(height: 8),
              SegmentedButton<AccountType>(
                showSelectedIcon: false,
                expandedInsets: EdgeInsets.zero,
                segments: [
                  for (final type in AccountType.values)
                    ButtonSegment(value: type, label: Text(type.label)),
                ],
                selected: {_type},
                onSelectionChanged: (selection) => setState(() => _type = selection.first),
              ),
              const SizedBox(height: 22),
              Text('OPENING BALANCE', style: AppText.eyebrow(context)),
              const SizedBox(height: 8),
              AmountField(
                controller: _balanceController,
                size: 40,
                centered: false,
                allowZero: true,
                underlineInset: 0,
              ),
              const SizedBox(height: 10),
              Text(
                balanceNote,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted, height: 1.5),
              ),
              if (_isEditing && !isDefault) ...[
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.hairlineSoft),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Archive this account',
                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Keeps its history, hides it from pickers. An account with '
                              'activity can’t be deleted.',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: _archived,
                        onChanged: (value) => setState(() => _archived = value),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(22, 8, 22, 16),
        child: FilledButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save account' : 'Add account'),
        ),
      ),
    );
  }
}
