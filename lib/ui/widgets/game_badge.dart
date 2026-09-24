import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class GameBadge extends StatelessWidget {
  const GameBadge({
    super.key,
    required this.label,
    this.icon = Icons.grid_view_rounded,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final style = Theme.of(context).textTheme.titleSmall;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.pill,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colors.accent),
            const SizedBox(width: AppSpacing.sm),
            Text(label, maxLines: 1, style: style),
          ],
        ),
      ),
    );
  }
}
