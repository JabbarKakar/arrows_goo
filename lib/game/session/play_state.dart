import 'package:meta/meta.dart';

import '../models/arrow.dart';
import '../models/board.dart';
import '../models/grid_pos.dart';

enum PlayKind { campaign, daily }

@immutable
class PlayConfig {
  const PlayConfig.campaign(this.levelNumber)
      : kind = PlayKind.campaign,
        dailyId = null;

  const PlayConfig.daily(this.dailyId)
      : kind = PlayKind.daily,
        levelNumber = 0;

  final PlayKind kind;
  final int levelNumber;
  final String? dailyId;

  bool get isDaily => kind == PlayKind.daily;

  @override
  bool operator ==(Object other) =>
      other is PlayConfig &&
      other.kind == kind &&
      other.levelNumber == levelNumber &&
      other.dailyId == dailyId;

  @override
  int get hashCode => Object.hash(kind, levelNumber, dailyId);
}

@immutable
class SlidingArrow {
  const SlidingArrow({
    required this.arrow,
    required this.from,
  });

  final Arrow arrow;
  final GridPos from;

  @override
  bool operator ==(Object other) =>
      other is SlidingArrow && other.arrow == arrow && other.from == from;

  @override
  int get hashCode => Object.hash(arrow, from);
}

@immutable
class PlayState {
  const PlayState({
    required this.board,
    this.config = const PlayConfig.campaign(1),
    this.sliding,
    this.hearts = maxHearts,
    this.hintsRemaining = freeHintsPerLevel,
    this.isWon = false,
    this.isFailed = false,
    this.isPaused = false,
    this.hintedPos,
    this.shakingPos,
    this.shakeNonce = 0,
    this.guidancePos,
  });

  static const maxHearts = 3;
  static const freeHintsPerLevel = 2;

  final Board board;
  final PlayConfig config;
  final SlidingArrow? sliding;
  final int hearts;
  final int hintsRemaining;
  final bool isWon;
  final bool isFailed;
  final bool isPaused;
  final GridPos? hintedPos;
  final GridPos? shakingPos;
  final int shakeNonce;
  final GridPos? guidancePos;

  int get levelNumber => config.levelNumber;

  bool get isDaily => config.isDaily;

  bool get isPerfect => isWon && hearts == maxHearts;

  bool get inputLocked =>
      isWon || isFailed || isPaused || sliding != null;

  PlayState copyWith({
    Board? board,
    PlayConfig? config,
    SlidingArrow? sliding,
    bool clearSliding = false,
    int? hearts,
    int? hintsRemaining,
    bool? isWon,
    bool? isFailed,
    bool? isPaused,
    GridPos? hintedPos,
    bool clearHinted = false,
    GridPos? shakingPos,
    bool clearShaking = false,
    int? shakeNonce,
    GridPos? guidancePos,
    bool clearGuidance = false,
  }) {
    return PlayState(
      board: board ?? this.board,
      config: config ?? this.config,
      sliding: clearSliding ? null : (sliding ?? this.sliding),
      hearts: hearts ?? this.hearts,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      isWon: isWon ?? this.isWon,
      isFailed: isFailed ?? this.isFailed,
      isPaused: isPaused ?? this.isPaused,
      hintedPos: clearHinted ? null : (hintedPos ?? this.hintedPos),
      shakingPos: clearShaking ? null : (shakingPos ?? this.shakingPos),
      shakeNonce: shakeNonce ?? this.shakeNonce,
      guidancePos: clearGuidance ? null : (guidancePos ?? this.guidancePos),
    );
  }
}
