import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: colors.gradient),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _TechFieldPainter(
                  line: colors.textPrimary,
                  glow: colors.accent,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.05,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: dark ? 0.55 : 0.12),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -180,
          left: -80,
          child: _GlowOrb(
            color: colors.orb,
            diameter: 340,
            alpha: dark ? 0.22 : 0.16,
          ),
        ),
        Positioned(
          bottom: -200,
          right: -80,
          child: _GlowOrb(
            color: colors.secondary,
            diameter: 280,
            alpha: dark ? 0.18 : 0.1,
          ),
        ),
        child,
      ],
    );
  }
}

class _TechFieldPainter extends CustomPainter {
  const _TechFieldPainter({required this.line, required this.glow});

  final Color line;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 52.0;
    for (var x = step; x < size.width; x += step) {
      grid.color = line.withValues(alpha: 0.045);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = step; y < size.height; y += step) {
      final fade = (1 - y / size.height).clamp(0.2, 1.0);
      grid.color = line.withValues(alpha: 0.055 * fade);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final horizon = size.height * 0.18;
    final band = Rect.fromLTWH(0, horizon, size.width, 1.2);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          colors: [
            glow.withValues(alpha: 0),
            glow.withValues(alpha: 0.55),
            glow.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, horizon, size.width, 2)),
    );
  }

  @override
  bool shouldRepaint(covariant _TechFieldPainter oldDelegate) =>
      oldDelegate.line != line || oldDelegate.glow != glow;
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.diameter,
    this.alpha = 0.2,
  });

  final Color color;
  final double diameter;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
