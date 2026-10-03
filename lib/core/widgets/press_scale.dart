import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// Gives a tappable [child] a quick press-down scale. It only listens to raw
/// pointer events, so the child's own InkWell or button keeps handling taps.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
    this.enabled = true,
  });

  final Widget child;
  final double pressedScale;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // Translucent so the whole box registers a press (including empty gaps in
      // the child) while taps still reach the child's own handlers.
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed && widget.enabled ? widget.pressedScale : 1,
        duration: AppMotion.scaled(context, AppMotion.fast),
        curve: AppMotion.curveOut,
        child: widget.child,
      ),
    );
  }
}
