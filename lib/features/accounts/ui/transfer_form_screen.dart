import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/utils/amount_input.dart';
import '../../../core/utils/confirm_dialog.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/amount_field.dart';
import '../../../core/widgets/form_card.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/transfer_model.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/transfer_provider.dart';
import '../utils/account_balance.dart';
import '../utils/transfer_preview.dart';
import 'widgets/account_picker_sheet.dart';

/// Moves money from one account to another, or edits [transfer]. A transfer is
/// not income or expense; its optional fee is the only part that counts as
/// spending.
class TransferFormScreen extends ConsumerStatefulWidget {
  const TransferFormScreen({super.key, this.transfer, this.initialFromAccountId});

  final TransferModel? transfer;

  /// Source chosen when starting a new transfer from one account's page.
  final String? initialFromAccountId;

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends ConsumerState<TransferFormScreen>
    with SingleTickerProviderStateMixin {
  static const _cardHeight = 80.0;
  static const _gap = 8.0;

  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.transfer == null ? '' : CurrencyFormatter.number(widget.transfer!.amount),
  );
  late final _feeController = TextEditingController(
    text: widget.transfer == null || widget.transfer!.fee == 0
        ? ''
        : CurrencyFormatter.number(widget.transfer!.fee),
  );
  late final _noteController = TextEditingController(text: widget.transfer?.note);
  late final AnimationController _swap = AnimationController(vsync: this);

  late DateTime _date = widget.transfer?.date ?? DateTime.now();
  late String? _fromId = widget.transfer?.fromAccountId ?? widget.initialFromAccountId;
  late String? _toId = widget.transfer?.toAccountId;
  bool _defaultsChosen = false;
  double _turns = 0;

  bool get _isEditing => widget.transfer != null;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_changed);
    _feeController.addListener(_changed);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _feeController.dispose();
    _noteController.dispose();
    _swap.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  double get _amount => ThousandsInputFormatter.parse(_amountController.text) ?? 0;
  double get _fee => ThousandsInputFormatter.parse(_feeController.text) ?? 0;

  /// A new transfer starts from the account last used as a source and goes to
  /// the first other active account.
  void _chooseDefaults(List<AccountModel> active) {
    if (_defaultsChosen || _isEditing || active.isEmpty) return;
    _defaultsChosen = true;

    final remembered = ref.read(lastTransferSourceProvider).value;
    _fromId ??= active.any((a) => a.id == remembered) ? remembered : active.first.id;
    if (!active.any((a) => a.id == _fromId)) _fromId = active.first.id;
    _toId ??= active.where((a) => a.id != _fromId).firstOrNull?.id;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickAccount({
    required bool from,
    required List<AccountModel> active,
    required Map<String, double> balances,
  }) async {
    final chosen = await showAccountPickerSheet(
      context,
      accounts: active,
      balances: balances,
      selectedId: from ? _fromId : _toId,
    );
    if (chosen == null) return;
    setState(() => from ? _fromId = chosen.id : _toId = chosen.id);
  }

  Future<void> _swapAccounts() async {
    if (_swap.isAnimating) return;
    final reduced = AppMotion.reduced(context);

    setState(() => _turns += 0.5);
    if (!reduced) {
      _swap.duration = AppMotion.slow;
      await _swap.forward(from: 0);
      if (!mounted) return;
    }
    setState(() {
      final from = _fromId;
      _fromId = _toId;
      _toId = from;
    });
    _swap.value = 0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final fromId = _fromId;
    final toId = _toId;
    if (fromId == null || toId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose both accounts first')),
      );
      return;
    }
    if (fromId == toId) return;

    final note = _noteController.text.trim();
    final notifier = ref.read(transferListProvider.notifier);
    final existing = widget.transfer;

    if (existing == null) {
      await notifier.addTransfer(
        fromAccountId: fromId,
        toAccountId: toId,
        amount: _amount,
        fee: _fee,
        date: _date,
        note: note.isEmpty ? null : note,
      );
    } else {
      await notifier.updateTransfer(
        existing.copyWith(
          fromAccountId: fromId,
          toAccountId: toId,
          amount: _amount,
          fee: _fee,
          date: _date,
          note: note.isEmpty ? null : note,
        ),
      );
    }
    // Best effort: remembering the source must never hold up closing the form.
    unawaited(ref.read(lastTransferSourceProvider).save(fromId));

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final existing = widget.transfer;
    if (existing == null) return;
    final confirmed = await confirmDialog(
      context,
      title: 'Delete transfer?',
      message: 'This also removes its fee entry and puts the money back.',
    );
    if (!confirmed || !mounted) return;
    await ref.read(transferListProvider.notifier).deleteTransfer(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<TransferModel>>>(transferListProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save transfer: $error')),
        ),
      );
    });

    final accounts = ref.watch(accountListProvider).value ?? const <AccountModel>[];
    final active = accounts.where((a) => !a.isArchived).toList();
    _chooseDefaults(active);

    // Balances as they stood before this transfer, so an edit does not count
    // itself twice.
    final balances = accountBalances(
      accounts: accounts,
      transactions: ref.watch(transactionListProvider).value ?? const [],
      transfers: ref.watch(transferListProvider).value ?? const [],
      defaultAccountId: ref.watch(defaultAccountIdProvider),
      excludingTransferId: widget.transfer?.id,
    );

    AccountModel? byId(String? id) => accounts.where((a) => a.id == id).firstOrNull;
    final from = byId(_fromId);
    final to = byId(_toId);
    final sameAccount = from != null && to != null && from.id == to.id;
    final preview = previewTransfer(
      fromBalance: from == null ? null : balances[from.id],
      toBalance: to == null ? null : balances[to.id],
      amount: _amount,
      fee: _fee,
      sameAccount: sameAccount,
    );

    final isLoading = ref.watch(transferListProvider).isLoading;
    final textTheme = Theme.of(context).textTheme;
    final canSave = !isLoading && !sameAccount;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit transfer' : 'New transfer')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
            children: [
              Center(child: Text('AMOUNT', style: AppText.eyebrow(context))),
              const SizedBox(height: 8),
              AmountField(controller: _amountController, enabled: !isLoading),
              const SizedBox(height: 20),
              _AccountCards(
                swap: _swap,
                turns: _turns,
                from: from,
                to: to,
                fromRight: _rightText(
                  balance: from == null ? null : balances[from.id],
                  after: preview.fromAfter,
                ),
                toRight: sameAccount
                    ? 'Same as From\npick another'
                    : _rightText(
                        balance: to == null ? null : balances[to.id],
                        after: preview.toAfter,
                      ),
                fromWarns: preview.insufficient,
                toWarns: sameAccount,
                onPickFrom: () => _pickAccount(from: true, active: active, balances: balances),
                onPickTo: () => _pickAccount(from: false, active: active, balances: balances),
                onSwap: _swapAccounts,
              ),
              const SizedBox(height: 16),
              FormCard(
                rows: [
                  FormCardRow.field(
                    label: 'Fee (optional)',
                    controller: _feeController,
                    hint: '0',
                    enabled: !isLoading,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      const ThousandsInputFormatter(),
                    ],
                  ),
                  FormCardRow.value(
                    label: 'Date',
                    value: DateFormatter.relativeDayWithDate(_date),
                    onTap: isLoading ? null : _pickDate,
                  ),
                  FormCardRow.field(
                    label: 'Note',
                    controller: _noteController,
                    hint: 'Optional',
                    enabled: !isLoading,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
                child: Text(
                  _isEditing
                      ? 'Saving also updates this transfer’s fee entry in Activity. Deleting '
                          'removes both and puts the money back.'
                      : 'The fee leaves ${from?.name ?? 'the source account'} and is counted as '
                          'an expense under Fees. The transfer itself is not.',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted, height: 1.5),
                ),
              ),
              if (sameAccount)
                _Notice('From and To are both ${from.name}. Pick a different account to move '
                    'money to.')
              else if (preview.insufficient)
                _Notice('${from!.name} holds ${CurrencyFormatter.number(balances[from.id] ?? 0)}, '
                    'less than this transfer plus its fee. You can still save it, for example if '
                    'the balance is out of date.'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(22, 8, 22, 16),
        child: Row(
          children: [
            Expanded(
              flex: _isEditing ? 2 : 1,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  disabledBackgroundColor: AppColors.track,
                  disabledForegroundColor: AppColors.textFaint,
                ),
                onPressed: canSave ? _submit : null,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing
                            ? 'Save changes'
                            : preview.insufficient
                                ? 'Save anyway'
                                : 'Save transfer',
                      ),
              ),
            ),
            if (_isEditing) ...[
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    foregroundColor: AppColors.expense,
                    backgroundColor: AppColors.noticeBackground,
                    side: const BorderSide(color: AppColors.noticeBorder),
                  ),
                  onPressed: isLoading ? null : _delete,
                  child: const Text('Delete'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _rightText({required double? balance, required double? after}) {
    if (balance == null || after == null) return null;
    String signed(double v) => '${v < 0 ? '−' : ''}${CurrencyFormatter.number(v.abs())}';
    return 'Balance ${signed(balance)}\nafter ${signed(after)}';
  }
}

class _Notice extends StatelessWidget {
  const _Notice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: AppColors.noticeBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.noticeBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.expense),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ivory,
                        height: 1.5,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The From and To cards with the swap button between them. The account names
/// and balances ("chips") are drawn above the cards so they can trade places
/// when the accounts are swapped, while the FROM and TO labels stay put.
class _AccountCards extends StatelessWidget {
  const _AccountCards({
    required this.swap,
    required this.turns,
    required this.from,
    required this.to,
    required this.fromRight,
    required this.toRight,
    required this.fromWarns,
    required this.toWarns,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onSwap,
  });

  final Animation<double> swap;
  final double turns;
  final AccountModel? from;
  final AccountModel? to;
  final String? fromRight;
  final String? toRight;
  final bool fromWarns;
  final bool toWarns;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onSwap;

  static const _travel = _TransferFormScreenState._cardHeight + _TransferFormScreenState._gap;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return SizedBox(
      height: _TransferFormScreenState._cardHeight * 2 + _TransferFormScreenState._gap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _TransferFormScreenState._cardHeight,
            child: _CardFrame(
              label: 'FROM',
              account: from,
              warns: fromWarns,
              onTap: onPickFrom,
            ),
          ),
          Positioned(
            top: _travel,
            left: 0,
            right: 0,
            height: _TransferFormScreenState._cardHeight,
            child: _CardFrame(label: 'TO', account: to, warns: toWarns, onTap: onPickTo),
          ),
          AnimatedBuilder(
            animation: swap,
            builder: (context, _) {
              final t = AppMotion.curveOut.transform(swap.value);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: _travel * t,
                    left: 0,
                    right: 0,
                    height: _TransferFormScreenState._cardHeight,
                    child: _Chip(label: 'FROM', account: from, right: fromRight, warns: fromWarns),
                  ),
                  Positioned(
                    top: _travel * (1 - t),
                    left: 0,
                    right: 0,
                    height: _TransferFormScreenState._cardHeight,
                    child: _Chip(label: 'TO', account: to, right: toRight, warns: toWarns),
                  ),
                ],
              );
            },
          ),
          Positioned(
            right: 62,
            top: _TransferFormScreenState._cardHeight + _TransferFormScreenState._gap / 2 - 22,
            child: Semantics(
              button: true,
              label: 'Swap accounts',
              excludeSemantics: true,
              onTap: onSwap,
              child: Material(
                color: AppColors.background,
                shape: const CircleBorder(side: BorderSide(color: AppColors.brassOutline)),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSwap,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: AnimatedRotation(
                      turns: turns,
                      duration: reduced ? Duration.zero : AppMotion.slow,
                      curve: AppMotion.curveOut,
                      child: const Icon(Icons.swap_vert_rounded, size: 20, color: AppColors.brass),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFrame extends StatelessWidget {
  const _CardFrame({
    required this.label,
    required this.account,
    required this.warns,
    required this.onTap,
  });

  final String label;
  final AccountModel? account;
  final bool warns;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label account: ${account?.name ?? 'not chosen'}',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: warns ? AppColors.noticeBorder : AppColors.hairline),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: AppText.eyebrow(context)),
                      const SizedBox(height: 2),
                      // Reserves the line the name is drawn on, in the chip layer.
                      Text(' ', style: AppText.amount(context, size: 24)),
                    ],
                  ),
                ),
                const Icon(Icons.expand_more_rounded, size: 18, color: AppColors.brass),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.account,
    required this.right,
    required this.warns,
  });

  final String label;
  final AccountModel? account;
  final String? right;
  final bool warns;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = account?.name;

    return IgnorePointer(
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 42),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(' ', style: AppText.eyebrow(context)),
                    const SizedBox(height: 2),
                    Text(
                      name ?? 'Choose an account',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.amount(
                        context,
                        size: 24,
                        color: name == null ? AppColors.textFaint : AppColors.ivory,
                      ),
                    ),
                  ],
                ),
              ),
              if (right != null)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    right!,
                    textAlign: TextAlign.end,
                    style: textTheme.bodySmall?.copyWith(
                      color: warns ? AppColors.expense : AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
