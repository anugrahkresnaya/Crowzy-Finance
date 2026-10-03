import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import 'press_scale.dart';

/// Floating pill bottom bar: four tabs around a central add button, with a
/// brass circle that glides to the selected tab.
class PillNavBar extends StatelessWidget {
  const PillNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
  });

  /// Selected tab, 0-3 (the add button is not a tab).
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;

  static const _tabs = [
    (icon: Icons.home_outlined, label: 'Home'),
    (icon: Icons.format_list_bulleted_rounded, label: 'Activity'),
    (icon: Icons.bar_chart_rounded, label: 'Reports'),
    (icon: Icons.auto_awesome_outlined, label: 'Ask AI'),
  ];

  static const _slotCount = 5;
  static const _addSlot = 2;
  static const _buttonSize = 48.0;

  /// The bar has five equal slots and the add button sits in the middle one,
  /// so tabs after the second shift one slot to the right.
  static int slotForTab(int tab) => tab < _addSlot ? tab : tab + 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: AppColors.hairline),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final slotWidth = constraints.maxWidth / _slotCount;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: AppMotion.scaled(context, AppMotion.navGlide),
                curve: AppMotion.curveOut,
                left: slotForTab(selectedIndex) * slotWidth + (slotWidth - _buttonSize) / 2,
                top: (constraints.maxHeight - _buttonSize) / 2,
                width: _buttonSize,
                height: _buttonSize,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.brass, shape: BoxShape.circle),
                ),
              ),
              Row(
                children: [
                  for (var slot = 0; slot < _slotCount; slot++)
                    Expanded(
                      child: Center(
                        child: slot == _addSlot
                            ? _AddButton(onTap: onAdd)
                            : _TabButton(
                                icon: _tabs[_tabForSlot(slot)].icon,
                                label: _tabs[_tabForSlot(slot)].label,
                                selected: _tabForSlot(slot) == selectedIndex,
                                onTap: () => onSelected(_tabForSlot(slot)),
                              ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static int _tabForSlot(int slot) => slot < _addSlot ? slot : slot - 1;
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: PressScale(
        pressedScale: 0.92,
        child: SizedBox(
          width: PillNavBar._buttonSize,
          height: PillNavBar._buttonSize,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Center(
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: selected ? AppColors.background : AppColors.textLabel),
                  duration: AppMotion.scaled(context, AppMotion.iconColor),
                  curve: AppMotion.curveOut,
                  builder: (context, color, _) => Icon(icon, size: 22, color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Add transaction',
      excludeSemantics: true,
      onTap: onTap,
      child: PressScale(
        pressedScale: 0.92,
        child: SizedBox(
          width: PillNavBar._buttonSize,
          height: PillNavBar._buttonSize,
          child: Material(
            color: AppColors.burgundy,
            shape: const CircleBorder(side: BorderSide(color: AppColors.brassOutline)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const Center(
                child: Icon(Icons.add_rounded, size: 24, color: AppColors.brass),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
