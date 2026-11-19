import 'package:flutter/material.dart';

import '../../data/models/transaction_type.dart';
import '../../features/accounts/ui/transfer_form_screen.dart';
import '../../features/ai_analyzer/ui/ai_analyzer_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/reports/ui/monthly_report_screen.dart';
import '../../features/transactions/ui/add_edit_transaction_screen.dart';
import '../../features/transactions/ui/transaction_list_screen.dart';
import '../../features/transactions/ui/widgets/add_chooser_sheet.dart';
import '../theme/app_motion.dart';
import '../utils/app_page_route.dart';
import 'pill_nav_bar.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  bool _forward = true;

  static const _tabs = [
    HomeScreen(),
    TransactionListScreen(),
    MonthlyReportScreen(),
    AiAnalyzerScreen(),
  ];

  /// Panels slide in from the direction of travel; the outgoing one just fades.
  static const _slideDistance = 0.09;

  void _select(int index) {
    if (index == _index) return;
    setState(() {
      _forward = index > _index;
      _index = index;
    });
  }

  Future<void> _add() async {
    final choice = await showAddChooserSheet(context);
    if (choice == null || !mounted) return;
    final screen = switch (choice) {
      AddChoice.expense => const AddEditTransactionScreen(),
      AddChoice.income => const AddEditTransactionScreen(initialType: TransactionType.income),
      AddChoice.transfer => const TransferFormScreen(),
    };
    pushSlide(context, screen);
  }

  Widget _transition(Widget child, Animation<double> animation) {
    final incoming = child.key == ValueKey<int>(_index);
    final direction = _forward ? 1.0 : -1.0;

    final faded = FadeTransition(opacity: animation, child: child);
    if (!incoming) return faded;

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(_slideDistance * direction, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: AppMotion.curveOut)),
      child: faded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppMotion.scaled(context, AppMotion.panelSlide),
        reverseDuration: AppMotion.scaled(context, AppMotion.fast),
        switchInCurve: AppMotion.curveOut,
        switchOutCurve: AppMotion.curveIn,
        transitionBuilder: reduced ? (child, _) => child : _transition,
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: _tabs[_index],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: PillNavBar(
          selectedIndex: _index,
          onSelected: _select,
          onAdd: _add,
        ),
      ),
    );
  }
}
