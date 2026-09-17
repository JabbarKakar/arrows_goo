import 'package:flutter/material.dart';

import '../../game/models/direction.dart';

class ArrowTile extends StatelessWidget {
  const ArrowTile({
    super.key,
    required this.direction,
    required this.color,
  });

  final Direction direction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomPaint(
          painter: _ArrowPainter(
            direction: direction,
            color: color.computeLuminance() > 0.55
                ? const Color(0xFF1D2B2A)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter({required this.direction, required this.color});

  final Direction direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(direction.radians);

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, -h * 0.32)
      ..lineTo(w * 0.28, h * 0.08)
      ..lineTo(w * 0.10, h * 0.08)
      ..lineTo(w * 0.10, h * 0.32)
      ..lineTo(-w * 0.10, h * 0.32)
      ..lineTo(-w * 0.10, h * 0.08)
      ..lineTo(-w * 0.28, h * 0.08)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) {
    return oldDelegate.direction != direction || oldDelegate.color != color;
  }
}
