import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../game/session/play_state.dart';

class HeartsHud extends StatelessWidget {
  const HeartsHud({super.key, required this.hearts});

  final int hearts;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.pill,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < PlayState.maxHearts; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.xs),
              Icon(
                i < hearts
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: Key('heart_$i'),
                size: 18,
                color: i < hearts
                    ? colors.error
                    : colors.error.withValues(alpha: 0.35),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
