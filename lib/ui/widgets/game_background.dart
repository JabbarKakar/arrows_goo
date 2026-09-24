import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GameBackground extends StatelessWidget {
  const GameBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: colors.gradient),
          ),
        ),
        Positioned(
          top: -150,
          right: -90,
          child: _GlowOrb(color: colors.orb, diameter: 280),
        ),
        Positioned(
          bottom: -170,
          left: -110,
          child: _GlowOrb(color: colors.secondary, diameter: 260, alpha: 0.16),
        ),
        child,
      ],
    );
  }
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
