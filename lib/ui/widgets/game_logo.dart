import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

class GameLogo extends StatelessWidget {
  const GameLogo({
    super.key,
    this.icon = Icons.north_east_rounded,
    this.size = 84,
    this.animate = false,
  });

  final IconData icon;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final mark = _Mark(icon: icon, size: size, colors: colors);
    if (!animate) {
      return _RingBox(turn: 0, color: colors.accent, size: size, child: mark);
    }
    return _LiveRing(size: size, color: colors.accent, child: mark);
  }
}

class _LiveRing extends StatefulWidget {
  const _LiveRing({
    required this.size,
    required this.color,
    required this.child,
  });

  final double size;
  final Color color;
  final Widget child;

  @override
  State<_LiveRing> createState() => _LiveRingState();
}

class _LiveRingState extends State<_LiveRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return _RingBox(
            turn: _controller.value,
            color: widget.color,
            size: widget.size,
            child: child!,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _RingBox extends StatelessWidget {
  const _RingBox({
    required this.turn,
    required this.color,
    required this.size,
    required this.child,
  });

  final double turn;
  final Color color;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final outer = size + 36;
    return SizedBox(
      width: outer,
      height: outer,
      child: CustomPaint(
        painter: _RingPainter(turn: turn, color: color),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.turn, required this.color});

  final double turn;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 2;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.9);
    const sweep = 0.85;
    final step = math.pi / 2;
    for (var i = 0; i < 4; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        turn * math.pi * 2 + i * step,
        sweep,
        false,
        arc,
      );
    }
    canvas.drawCircle(
      center,
      radius - 7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.turn != turn || oldDelegate.color != color;
}

class _Mark extends StatelessWidget {
  const _Mark({required this.icon, required this.size, required this.colors});

  final IconData icon;
  final double size;
  final GameColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(colors.accent, Colors.white, 0.28)!,
            colors.accent,
            colors.secondary,
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        boxShadow: AppShadows.glow(colors.accent),
      ),
      child: Icon(icon, size: size * 0.46, color: colors.onAccent),
    );
  }
}
