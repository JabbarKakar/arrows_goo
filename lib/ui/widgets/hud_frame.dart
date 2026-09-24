import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Corner brackets that turn a panel into a HUD frame.
class HudFrame extends StatelessWidget {
  const HudFrame({super.key, required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? GameColors.of(context).accent;
    return CustomPaint(foregroundPainter: _CornerPainter(accent), child: child);
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.square;
    const arm = 16.0;
    const inset = 1.0;
    final marks = <Offset>[
      Offset(inset, inset + arm),
      Offset(inset, inset),
      Offset(inset + arm, inset),
      Offset(size.width - inset - arm, inset),
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + arm),
      Offset(inset, size.height - inset - arm),
      Offset(inset, size.height - inset),
      Offset(inset + arm, size.height - inset),
      Offset(size.width - inset - arm, size.height - inset),
      Offset(size.width - inset, size.height - inset),
      Offset(size.width - inset, size.height - inset - arm),
    ];
    for (var i = 0; i < marks.length; i += 3) {
      final path = Path()
        ..moveTo(marks[i].dx, marks[i].dy)
        ..lineTo(marks[i + 1].dx, marks[i + 1].dy)
        ..lineTo(marks[i + 2].dx, marks[i + 2].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}
