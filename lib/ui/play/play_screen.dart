import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_settings.dart';
import '../../core/storage/tutorial_seen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../game/levels/difficulty.dart';
import '../../game/session/play_session.dart';
import '../widgets/game_app_bar.dart';
import '../widgets/game_board.dart';
import '../widgets/game_button.dart';
import '../widgets/game_caption.dart';
import '../widgets/game_card.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/hearts_hud.dart';
import '../widgets/zoomable_board.dart';
import 'clear_burst.dart';
import 'play_sheet.dart';
import 'tutorial_coach.dart';

class PlayScreen extends ConsumerWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(playSessionProvider);
    final notifier = ref.read(playSessionProvider.notifier);
    final tutorialSeen = ref.watch(tutorialSeenProvider);
    final celebrations = ref.watch(appSettingsProvider).celebrationsEnabled;
    final colors = GameColors.of(context);
    final showTutorial = !tutorialSeen && !session.isWon && !session.isFailed;
    final title = session.isDaily
        ? 'Daily'
        : DifficultyTier.levelTitle(session.levelNumber);

    ref.listen(playSessionProvider, (previous, next) {
      if (previous != null &&
          previous.sliding == null &&
          next.sliding != null &&
          !ref.read(tutorialSeenProvider)) {
        unawaited(ref.read(tutorialSeenProvider.notifier).markSeen());
      }
    });

    return GameScaffold(
      maxWidth: 720,
      appBar: GameAppBar(
        title: title,
        leading: IconButton(
          key: const Key('pause_button'),
          tooltip: session.isPaused ? 'Resume' : 'Pause',
          onPressed: session.isWon || session.isFailed
              ? null
              : (session.isPaused ? notifier.resume : notifier.pause),
          icon: Icon(
            session.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: HeartsHud(hearts: session.hearts),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: AppSpacing.pageCompact,
              child: Column(
                children: [
                  Expanded(
                    child: GameCard(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: ZoomableBoard(
                        resetToken: (session.levelNumber, session.isDaily),
                        child: Center(
                          child: RepaintBoundary(
                            child: GameBoard(
                              board: session.board,
                              sliding: session.sliding,
                              enabled: !session.inputLocked,
                              guidancePos: session.guidancePos,
                              hintedPos: session.hintedPos,
                              shakingPos: session.shakingPos,
                              shakeNonce: session.shakeNonce,
                              onTap: (pos) => notifier.tap(pos.row, pos.col),
                              onSlideComplete: () {
                                unawaited(notifier.completeSlide());
                              },
                              onLongPressStart: notifier.startGuidance,
                              onLongPressEnd: notifier.clearGuidance,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      GameButton(
                        key: const Key('hint_button'),
                        variant: GameButtonVariant.secondary,
                        icon: Icons.lightbulb_outline_rounded,
                        onPressed: session.inputLocked
                            ? null
                            : (session.hintsRemaining > 0
                                  ? notifier.hint
                                  : notifier.extraHint),
                        label: session.hintsRemaining > 0
                            ? 'Hint · ${session.hintsRemaining}'
                            : 'Extra hint',
                      ),
                      if (kDebugMode && !session.isDaily)
                        GameButton(
                          key: const Key('debug_next_level_button'),
                          variant: GameButtonVariant.tonal,
                          icon: Icons.skip_next_rounded,
                          label: 'Next Level',
                          onPressed: notifier.nextLevel,
                        ),
                    ],
                  ),
                  if (session.hintsRemaining <= 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const GameCaption('Ad placeholder — extra hint'),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  if (showTutorial)
                    TutorialCoach(
                      onDismiss: () {
                        unawaited(
                          ref.read(tutorialSeenProvider.notifier).markSeen(),
                        );
                      },
                    )
                  else
                    const GameCaption(
                      'Tap a free arrow, or long-press for guidance.',
                    ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            if (session.isWon && celebrations)
              const Positioned.fill(
                child: ClearBurst(key: Key('clear_confetti')),
              ),
            if (session.isPaused)
              Positioned.fill(
                child: PlaySheet(
                  title: 'Paused',
                  icon: Icons.pause_rounded,
                  iconColor: colors.accent,
                  actions: [
                    GameButton(
                      key: const Key('resume_button'),
                      expand: true,
                      label: 'Resume',
                      onPressed: notifier.resume,
                    ),
                    GameButton(
                      key: const Key('pause_restart_button'),
                      expand: true,
                      variant: GameButtonVariant.secondary,
                      label: 'Restart',
                      onPressed: notifier.restart,
                    ),
                    GameButton(
                      expand: true,
                      variant: GameButtonVariant.secondary,
                      label: 'Home',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            if (session.isWon)
              Positioned.fill(
                child: PlaySheet(
                  title: 'Cleared!',
                  icon: Icons.verified_rounded,
                  iconColor: colors.success,
                  subtitle: session.isDaily
                      ? 'Come back tomorrow for a new grid.'
                      : session.isPerfect
                      ? 'Perfect — no hearts lost'
                      : '${session.hearts} ${session.hearts == 1 ? 'heart' : 'hearts'} left',
                  actions: [
                    if (!session.isDaily)
                      GameButton(
                        key: const Key('next_level_button'),
                        expand: true,
                        label: 'Next',
                        onPressed: notifier.nextLevel,
                      ),
                    GameButton(
                      key: const Key('play_again_button'),
                      expand: true,
                      variant: GameButtonVariant.secondary,
                      label: 'Play again',
                      onPressed: notifier.restart,
                    ),
                    GameButton(
                      expand: true,
                      variant: GameButtonVariant.secondary,
                      label: 'Home',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            if (session.isFailed)
              Positioned.fill(
                child: PlaySheet(
                  title: 'Out of hearts',
                  icon: Icons.favorite_border_rounded,
                  iconColor: colors.error,
                  subtitle: 'Try a different order, or continue this board.',
                  actions: [
                    GameButton(
                      key: const Key('continue_button'),
                      expand: true,
                      label: 'Continue',
                      onPressed: notifier.continueWithHeart,
                    ),
                    const GameCaption('Ad placeholder — restores one heart'),
                    GameButton(
                      key: const Key('restart_button'),
                      expand: true,
                      variant: GameButtonVariant.secondary,
                      label: 'Restart',
                      onPressed: notifier.restart,
                    ),
                    GameButton(
                      expand: true,
                      variant: GameButtonVariant.secondary,
                      label: 'Home',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
