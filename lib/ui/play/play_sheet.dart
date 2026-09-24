import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_durations.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/game_card.dart';
import '../widgets/game_caption.dart';
import '../widgets/hud_frame.dart';

class PlaySheet extends StatelessWidget {
  const PlaySheet({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    this.subtitle,
    required this.actions,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: ColoredBox(
        color: colors.background.withValues(alpha: 0.62),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.97, end: 1),
                duration: AppDurations.fast,
                curve: Curves.easeOutCubic,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: HudFrame(
                  color: iconColor,
                  child: GameCard(
                    radius: AppRadius.xl,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: iconColor.withValues(alpha: 0.14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppSpacing.sm + AppSpacing.xs,
                              ),
                              child: Icon(icon, color: iconColor, size: 28),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          GameCaption(subtitle!),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppSpacing.sm),
                          actions[i],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
