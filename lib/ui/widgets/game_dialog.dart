import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'game_button.dart';
import 'game_card.dart';
import 'hud_frame.dart';

abstract final class GameDialog {
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    Key? confirmKey,
  }) async {
    final colors = GameColors.of(context);
    final result = await showDialog<bool>(
      context: context,
      barrierColor: colors.overlay,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: HudFrame(
            color: colors.warning,
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
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.warning.withValues(alpha: 0.14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppSpacing.sm + AppSpacing.xs,
                      ),
                      child: Icon(
                        Icons.restart_alt_rounded,
                        color: colors.warning,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: GameButton(
                          expand: true,
                          variant: GameButtonVariant.secondary,
                          label: cancelLabel,
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: GameButton(
                          key: confirmKey,
                          expand: true,
                          variant: GameButtonVariant.destructive,
                          label: confirmLabel,
                          onPressed: () => Navigator.pop(context, true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
