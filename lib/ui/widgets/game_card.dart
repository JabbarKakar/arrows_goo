import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadius.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radiusAll = BorderRadius.circular(radius);
    final sheen = colors.accent.withValues(alpha: dark ? 0.75 : 0.45);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radiusAll,
        boxShadow: AppShadows.card(Theme.of(context).brightness),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(colors.card, colors.accent, dark ? 0.1 : 0.05)!,
            colors.card.withValues(alpha: dark ? 0.9 : 0.96),
          ],
        ),
        border: Border.all(
          color: Color.lerp(colors.border, colors.accent, dark ? 0.4 : 0.22)!,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 22,
            right: 22,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      sheen.withValues(alpha: 0),
                      sheen,
                      sheen.withValues(alpha: 0),
                    ],
                  ),
                ),
                child: const SizedBox(height: 1.5),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}
