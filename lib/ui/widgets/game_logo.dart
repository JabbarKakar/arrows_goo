import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

class GameLogo extends StatelessWidget {
  const GameLogo({
    super.key,
    this.icon = Icons.north_east_rounded,
    this.size = 88,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.accent, colors.secondary],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: AppShadows.glow(colors.accent),
      ),
      child: Icon(icon, size: size * 0.46, color: colors.onAccent),
    );
  }
}
