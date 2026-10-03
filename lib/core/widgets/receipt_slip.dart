import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// A receipt: ivory paper with a torn edge, set in a typewriter face. Used for
/// the records you drill into (a transaction, a day, an AI draft) so they read
/// as an object lying on the dark screen. Compose it from the parts below.
class ReceiptSlip extends StatelessWidget {
  const ReceiptSlip({
    super.key,
    required this.children,
    this.tornTop = false,
    this.tornBottom = true,
  });

  final List<Widget> children;
  final bool tornTop;
  final bool tornBottom;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TornEdgeClipper(top: tornTop, bottom: tornBottom),
      child: Container(
        width: double.infinity,
        color: AppColors.paper,
        padding: EdgeInsets.fromLTRB(
          24,
          (tornTop ? TornEdgeClipper.toothHeight : 0) + 20,
          24,
          (tornBottom ? TornEdgeClipper.toothHeight : 0) + 16,
        ),
        child: DefaultTextStyle(
          style: ReceiptText.mono(context),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      ),
    );
  }
}

/// Cuts a row of triangular teeth along the top and/or bottom edge.
class TornEdgeClipper extends CustomClipper<Path> {
  const TornEdgeClipper({this.top = false, this.bottom = true});

  final bool top;
  final bool bottom;

  static const toothWidth = 14.0;
  static const toothHeight = 10.0;

  /// The paper's outline for a [size] sheet. Teeth are spread evenly so the
  /// pattern always ends on a full tooth at both corners.
  static Path outline(Size size, {required bool top, required bool bottom}) {
    final teeth = math.max(1, (size.width / toothWidth).round());
    final step = size.width / teeth;
    final path = Path();

    if (top) {
      path.moveTo(0, toothHeight);
      for (var i = 0; i < teeth; i++) {
        path
          ..lineTo(i * step + step / 2, 0)
          ..lineTo((i + 1) * step, toothHeight);
      }
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
    }

    if (bottom) {
      path.lineTo(size.width, size.height - toothHeight);
      for (var i = teeth; i > 0; i--) {
        path
          ..lineTo(i * step - step / 2, size.height)
          ..lineTo((i - 1) * step, size.height - toothHeight);
      }
    } else {
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    return path..close();
  }

  @override
  Path getClip(Size size) => outline(size, top: top, bottom: bottom);

  @override
  bool shouldReclip(TornEdgeClipper oldClipper) => oldClipper.top != top || oldClipper.bottom != bottom;
}

/// Text styles for the slip: a typewriter face for lines, the serif for amounts.
class ReceiptText {
  ReceiptText._();

  static TextStyle mono(BuildContext context, {double size = 14, bool bold = false, Color? color}) {
    return GoogleFonts.courierPrime(
      fontSize: size,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color ?? AppColors.ink,
      height: 1.3,
    );
  }

  static TextStyle muted(BuildContext context, {double size = 12}) =>
      mono(context, size: size, color: AppColors.inkMuted);

  /// Serif figure for the slip's big amounts.
  static TextStyle amount(BuildContext context, {double size = 30, Color color = AppColors.oxblood}) {
    return AppText.amount(context, size: size, color: color).copyWith(fontWeight: FontWeight.w700);
  }
}

/// The slip's masthead: a letter-spaced serif title and a small caption.
class ReceiptHeading extends StatelessWidget {
  const ReceiptHeading({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.amount(context, size: 22, color: AppColors.ink).copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 22 * 0.14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: ReceiptText.muted(context, size: 12).copyWith(letterSpacing: 12 * 0.14),
        ),
      ],
    );
  }
}

/// A dashed rule between sections of the slip.
class ReceiptDivider extends StatelessWidget {
  const ReceiptDivider({super.key, this.margin = const EdgeInsets.symmetric(vertical: 14)});

  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: const SizedBox(
        height: 1.5,
        width: double.infinity,
        child: CustomPaint(painter: _DashedLinePainter()),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.inkRule
      ..strokeWidth = 1.5;
    const dash = 5.0;
    const gap = 3.0;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(Offset(x, size.height / 2), Offset(math.min(x + dash, size.width), size.height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}

/// A label on the left and a value on the right.
class ReceiptRow extends StatelessWidget {
  const ReceiptRow({super.key, required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: ReceiptText.muted(context, size: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: ReceiptText.mono(context, bold: bold),
            ),
          ),
        ],
      ),
    );
  }
}

/// One line item: a title with a caption beneath, and an amount.
class ReceiptLine extends StatelessWidget {
  const ReceiptLine({super.key, required this.title, required this.caption, required this.amount});

  final String title;
  final String caption;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ReceiptText.mono(context, bold: true)),
                if (caption.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(caption, style: ReceiptText.muted(context, size: 11)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(amount, style: ReceiptText.mono(context)),
        ],
      ),
    );
  }
}

/// The bottom line: a bold label and a large serif total, with an optional
/// small note beneath.
class ReceiptTotal extends StatelessWidget {
  const ReceiptTotal({
    super.key,
    required this.label,
    required this.amount,
    this.note,
    this.color = AppColors.oxblood,
  });

  final String label;
  final String amount;
  final String? note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(child: Text(label, style: ReceiptText.mono(context, bold: true))),
            Text(amount, style: ReceiptText.amount(context, color: color)),
          ],
        ),
        if (note != null && note!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              note!,
              textAlign: TextAlign.end,
              style: ReceiptText.muted(context, size: 11),
            ),
          ),
      ],
    );
  }
}

/// A rotated, outlined word like PAID or DRAFT, stamped on the slip.
class ReceiptStamp extends StatelessWidget {
  const ReceiptStamp({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -12 * math.pi / 180,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.oxblood, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: ReceiptText.mono(context, size: 15, bold: true, color: AppColors.oxblood)
              .copyWith(letterSpacing: 15 * 0.2),
        ),
      ),
    );
  }
}

/// A decorative barcode. The bars are fixed, not derived from any data.
class ReceiptBarcode extends StatelessWidget {
  const ReceiptBarcode({super.key, this.height = 34});

  final double height;

  // x, width pairs on a 200-unit-wide strip.
  static const _bars = <(double, double)>[
    (0, 2), (5, 1), (8, 3), (14, 1), (18, 2), (23, 1), (27, 3), (33, 1), (37, 2), (42, 3),
    (48, 1), (52, 2), (57, 1), (61, 3), (67, 1), (71, 2), (76, 3), (82, 1), (86, 2), (91, 1),
    (95, 3), (101, 2), (106, 1), (110, 3), (116, 1), (120, 2), (125, 3), (131, 1), (135, 2),
    (140, 1), (144, 3), (150, 2), (155, 1), (159, 3), (165, 1), (169, 2), (174, 3), (180, 1),
    (184, 2), (189, 1), (193, 3), (198, 2),
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: const CustomPaint(painter: _BarcodePainter()),
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  const _BarcodePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.ink;
    final scale = size.width / 200;
    for (final (x, width) in ReceiptBarcode._bars) {
      canvas.drawRect(Rect.fromLTWH(x * scale, 0, width * scale, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter oldDelegate) => false;
}

/// A small centred line of letter-spaced text, e.g. a sign-off.
class ReceiptFooter extends StatelessWidget {
  const ReceiptFooter(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: ReceiptText.muted(context, size: 11).copyWith(letterSpacing: 11 * 0.16),
    );
  }
}
