import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/arrow_palette.dart';

class ClearBurst extends StatefulWidget {
  const ClearBurst({super.key});

  @override
  State<ClearBurst> createState() => _ClearBurstState();
}

class _Particle {
  const _Particle({
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.spin,
  });

  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double spin;
}

class _ClearBurstState extends State<ClearBurst>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1200);

  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = math.Random(7);
    _particles = List.generate(28, (i) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 90 + rng.nextDouble() * 200;
      return _Particle(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 50,
        color: ArrowPalette.of(i),
        size: 5 + rng.nextDouble() * 6,
        spin: (rng.nextDouble() - 0.5) * 8,
      );
    });
    _controller = AnimationController(vsync: this, duration: _duration)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _BurstPainter(
              particles: _particles,
              t: Curves.easeOutCubic.transform(_controller.value),
            ),
          );
        },
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  const _BurstPainter({required this.particles, required this.t});

  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final origin = Offset(size.width / 2, size.height / 2);
    final fade = (1 - t).clamp(0.0, 1.0);
    for (final p in particles) {
      final dx = p.vx * t;
      final dy = p.vy * t + 140 * t * t;
      final center = origin + Offset(dx, dy);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(p.spin * t);
      final paint = Paint()..color = p.color.withValues(alpha: 0.85 * fade);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => oldDelegate.t != t;
}
