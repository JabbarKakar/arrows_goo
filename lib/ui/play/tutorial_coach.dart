import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/game_card.dart';

class TutorialCoach extends StatelessWidget {
  const TutorialCoach({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final text = Theme.of(context).textTheme;
    return GameCard(
      key: const Key('tutorial_overlay'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tap an arrow that can reach the edge.',
            textAlign: TextAlign.center,
            style: text.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Long-press to preview its path.',
            textAlign: TextAlign.center,
            style: text.bodyLarge,
          ),
          TextButton(
            key: const Key('tutorial_got_it'),
            onPressed: onDismiss,
            child: Text(
              'Got it',
              style: text.labelLarge?.copyWith(color: colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}
