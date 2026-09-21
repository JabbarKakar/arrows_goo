import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_settings.dart';
import '../../core/storage/tutorial_seen.dart';
import '../../game/levels/difficulty.dart';
import '../../game/session/play_session.dart';
import '../widgets/game_board.dart';
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
    final showTutorial =
        !tutorialSeen && !session.isWon && !session.isFailed;

    ref.listen(playSessionProvider, (previous, next) {
      if (previous != null &&
          previous.sliding == null &&
          next.sliding != null &&
          !ref.read(tutorialSeenProvider)) {
        unawaited(ref.read(tutorialSeenProvider.notifier).markSeen());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          session.isDaily
              ? 'Daily'
              : 'Level ${session.levelNumber} · ${DifficultyTier.forLevel(session.levelNumber).label}',
        ),
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
          if (kDebugMode && !session.isDaily)
            TextButton(
              key: const Key('debug_next_level_button'),
              onPressed: notifier.nextLevel,
              child: const Text('Next Level'),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: HeartsHud(hearts: session.hearts),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
            child: Column(
              children: [
                Expanded(
                  child: ZoomableBoard(
                    resetToken: (
                      session.levelNumber,
                      session.isDaily,
                    ),
                    child: Center(
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
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('hint_button'),
                      onPressed: session.inputLocked
                          ? null
                          : (session.hintsRemaining > 0
                                ? notifier.hint
                                : notifier.extraHint),
                      icon: const Icon(Icons.lightbulb_outline_rounded),
                      label: Text(
                        session.hintsRemaining > 0
                            ? 'Hint · ${session.hintsRemaining}'
                            : 'Extra hint',
                      ),
                    ),
                    if (kDebugMode && !session.isDaily)
                      FilledButton.tonalIcon(
                        key: const Key('debug_next_level_body_button'),
                        onPressed: notifier.nextLevel,
                        icon: const Icon(Icons.skip_next_rounded),
                        label: const Text('Next Level'),
                      ),
                  ],
                ),
                if (session.hintsRemaining <= 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Ad placeholder — extra hint',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: 12),
                if (showTutorial)
                  TutorialCoach(
                    onDismiss: () {
                      unawaited(
                        ref.read(tutorialSeenProvider.notifier).markSeen(),
                      );
                    },
                  )
                else
                  Text(
                    'Tap a free arrow, or long-press for guidance.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (session.isWon && celebrations)
            const Positioned.fill(
              child: ClearBurst(key: Key('clear_confetti')),
            ),
          if (session.isPaused)
            PlaySheet(
              title: 'Paused',
              actions: [
                FilledButton(
                  key: const Key('resume_button'),
                  onPressed: notifier.resume,
                  child: const Text('Resume'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  key: const Key('pause_restart_button'),
                  onPressed: notifier.restart,
                  child: const Text('Restart'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Home'),
                ),
              ],
            ),
          if (session.isWon)
            PlaySheet(
              title: 'Cleared!',
              subtitle: session.isDaily
                  ? 'Come back tomorrow for a new grid.'
                  : session.isPerfect
                  ? 'Perfect — no hearts lost'
                  : '${session.hearts} ${session.hearts == 1 ? 'heart' : 'hearts'} left',
              actions: [
                if (!session.isDaily) ...[
                  FilledButton(
                    key: const Key('next_level_button'),
                    onPressed: notifier.nextLevel,
                    child: const Text('Next'),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton(
                  key: const Key('play_again_button'),
                  onPressed: notifier.restart,
                  child: const Text('Play again'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Home'),
                ),
              ],
            ),
          if (session.isFailed)
            PlaySheet(
              title: 'Out of hearts',
              subtitle: 'Try a different order, or continue this board.',
              actions: [
                FilledButton(
                  key: const Key('continue_button'),
                  onPressed: notifier.continueWithHeart,
                  child: const Text('Continue'),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ad placeholder — restores one heart',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  key: const Key('restart_button'),
                  onPressed: notifier.restart,
                  child: const Text('Restart'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Home'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
