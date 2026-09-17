import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feel/feel_service.dart';
import '../../core/storage/campaign_progress.dart';
import '../../core/storage/daily_progress.dart';
import '../engine/board_engine.dart';
import '../levels/level_catalog.dart';
import '../models/grid_pos.dart';
import 'play_state.dart';

final playConfigProvider =
    StateProvider<PlayConfig>((ref) => const PlayConfig.campaign(1));

class PlaySessionNotifier extends AutoDisposeNotifier<PlayState> {
  @override
  PlayState build() {
    return _fresh(ref.read(playConfigProvider));
  }

  PlayState _fresh(PlayConfig config) {
    final catalog = ref.read(levelCatalogProvider);
    final board = config.isDaily
        ? catalog.boardForDaily(config.dailyId!)
        : catalog.boardFor(config.levelNumber);
    return PlayState(board: board, config: config);
  }

  void tap(int row, int col) {
    if (state.inputLocked) return;
    final arrow = state.board.at(row, col);
    if (arrow == null) return;

    if (BoardEngine.isMovable(state.board, row, col)) {
      unawaited(ref.read(feelServiceProvider).validMove());
      state = state.copyWith(
        board: state.board.removeAt(row, col),
        sliding: SlidingArrow(arrow: arrow, from: GridPos(row, col)),
        clearHinted: true,
        clearGuidance: true,
        clearShaking: true,
      );
      return;
    }

    unawaited(ref.read(feelServiceProvider).blockedTap());
    final remaining = state.hearts - 1;
    state = state.copyWith(
      hearts: remaining,
      isFailed: remaining <= 0,
      shakingPos: GridPos(row, col),
      shakeNonce: state.shakeNonce + 1,
      clearGuidance: true,
    );
  }

  Future<void> completeSlide() async {
    if (state.sliding == null) return;
    final won = state.board.isCleared;
    state = state.copyWith(
      clearSliding: true,
      isWon: won,
    );
    if (!won) return;
    unawaited(ref.read(feelServiceProvider).cleared());
    if (state.isDaily) {
      await ref.read(dailyProgressProvider.notifier).markComplete(state.config.dailyId!);
    } else {
      await ref.read(campaignProgressProvider.notifier).completeLevel(state.levelNumber);
    }
  }

  void hint() {
    if (state.inputLocked || state.hintsRemaining <= 0) return;
    final movable = BoardEngine.movablePositions(state.board);
    if (movable.isEmpty) return;
    state = state.copyWith(
      hintedPos: movable.first,
      hintsRemaining: state.hintsRemaining - 1,
    );
  }

  void extraHint() {
    if (state.inputLocked) return;
    if (state.hintsRemaining > 0) {
      hint();
      return;
    }
    state = state.copyWith(hintsRemaining: 1);
    hint();
  }

  void continueWithHeart() {
    if (!state.isFailed) return;
    state = state.copyWith(isFailed: false, hearts: 1);
  }

  void startGuidance(GridPos pos) {
    if (state.inputLocked) return;
    if (state.board.atPos(pos) == null) return;
    state = state.copyWith(guidancePos: pos);
  }

  void clearGuidance() {
    if (state.guidancePos == null) return;
    state = state.copyWith(clearGuidance: true);
  }

  void pause() {
    if (state.isWon || state.isFailed || state.sliding != null) return;
    state = state.copyWith(isPaused: true, clearGuidance: true);
  }

  void resume() {
    if (!state.isPaused) return;
    state = state.copyWith(isPaused: false);
  }

  void restart() {
    state = _fresh(state.config);
  }

  void nextLevel() {
    if (state.isDaily) return;
    state = _fresh(PlayConfig.campaign(state.levelNumber + 1));
  }
}

final playSessionProvider =
    NotifierProvider.autoDispose<PlaySessionNotifier, PlayState>(
      PlaySessionNotifier.new,
    );
