import '../levels/difficulty.dart';
import '../models/arrow.dart';
import '../models/board.dart';
import '../models/direction.dart';
import '../models/grid_pos.dart';
import 'board_engine.dart';

class SeededRng {
  SeededRng(int seed) : _state = seed & 0x7fffffff;

  int _state;

  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max');
    }
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state % max;
  }

  void shuffle<T>(List<T> items) {
    for (var i = items.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = items[i];
      items[i] = items[j];
      items[j] = tmp;
    }
  }
}

class CampaignSpec {
  const CampaignSpec({
    required this.rows,
    required this.cols,
    required this.fillCount,
    this.tier = DifficultyTier.medium,
    this.blockChance = 7,
  });

  final int rows;
  final int cols;

  /// Target number of occupied cells (not piece count).
  final int fillCount;
  final DifficultyTier tier;

  /// Out of 10 placements, how often a new head sits on an earlier exit lane.
  final int blockChance;

  factory CampaignSpec.forLevel(int level) {
    final clamped = level < 1 ? 1 : level;
    final tier = DifficultyTier.forLevel(clamped);
    final start = switch (tier) {
      DifficultyTier.easy => 1,
      DifficultyTier.medium => 21,
      DifficultyTier.hard => 41,
      DifficultyTier.superHard => 71,
      DifficultyTier.nightmarish => 101,
    };
    final end = switch (tier) {
      DifficultyTier.easy => 20,
      DifficultyTier.medium => 40,
      DifficultyTier.hard => 70,
      DifficultyTier.superHard => 100,
      DifficultyTier.nightmarish => 160,
    };
    final size0 = switch (tier) {
      DifficultyTier.easy => 8,
      DifficultyTier.medium => 16,
      DifficultyTier.hard => 28,
      DifficultyTier.superHard => 42,
      DifficultyTier.nightmarish => 50,
    };
    final size1 = switch (tier) {
      DifficultyTier.easy => 14,
      DifficultyTier.medium => 24,
      DifficultyTier.hard => 38,
      DifficultyTier.superHard => 48,
      DifficultyTier.nightmarish => 58,
    };
    final occ0 = switch (tier) {
      DifficultyTier.easy => 0.42,
      DifficultyTier.medium => 0.68,
      DifficultyTier.hard => 0.84,
      DifficultyTier.superHard => 0.90,
      DifficultyTier.nightmarish => 0.94,
    };
    final occ1 = switch (tier) {
      DifficultyTier.easy => 0.58,
      DifficultyTier.medium => 0.80,
      DifficultyTier.hard => 0.90,
      DifficultyTier.superHard => 0.94,
      DifficultyTier.nightmarish => 0.97,
    };
    final block0 = switch (tier) {
      DifficultyTier.easy => 1,
      DifficultyTier.medium => 5,
      DifficultyTier.hard => 8,
      DifficultyTier.superHard => 9,
      DifficultyTier.nightmarish => 10,
    };
    final block1 = switch (tier) {
      DifficultyTier.easy => 3,
      DifficultyTier.medium => 7,
      DifficultyTier.hard => 9,
      DifficultyTier.superHard => 10,
      DifficultyTier.nightmarish => 10,
    };
    final span = end - start;
    final t = span <= 0
        ? 1.0
        : ((clamped - start) / span).clamp(0.0, 1.0);
    final size = (size0 + (size1 - size0) * t).round();
    final occupancy = occ0 + (occ1 - occ0) * t;
    final blockChance = (block0 + (block1 - block0) * t).round();
    return CampaignSpec(
      rows: size,
      cols: size,
      fillCount: (size * size * occupancy).round(),
      tier: tier,
      blockChance: blockChance < 0
          ? 0
          : (blockChance > 10 ? 10 : blockChance),
    );
  }
}

class LevelGenerator {
  LevelGenerator({required this.seed});

  final int seed;

  Board generate(CampaignSpec spec) {
    final rng = SeededRng(seed);
    var board = Board.empty(spec.rows, spec.cols);
    var nextId = 0;
    var occupied = 0;

    // Reverse-place mixed lengths so later pieces sit on earlier exit lanes
    // and block them. That gives a real solve order, not an all-free board.
    board = _fill(
      board,
      rng,
      spec,
      nextId,
      occupied,
      minLength: 1,
      target: spec.fillCount,
      maxFailures: switch (spec.tier) {
        DifficultyTier.easy => 70,
        DifficultyTier.medium => 120,
        DifficultyTier.hard => 180,
        DifficultyTier.superHard => 240,
        DifficultyTier.nightmarish => 320,
      },
    );
    occupied = _occupiedCount(board);
    nextId = occupied == 0 ? 0 : _maxId(board) + 1;
    board = _absorbHoles(board, rng);
    occupied = _occupiedCount(board);
    nextId = occupied == 0 ? 0 : _maxId(board) + 1;
    if (spec.tier == DifficultyTier.easy) return board;
    return _fillSingles(board, rng, spec, nextId, occupied);
  }

  Board _fill(
    Board board,
    SeededRng rng,
    CampaignSpec spec,
    int nextId,
    int occupied, {
    required int minLength,
    required int target,
    required int maxFailures,
  }) {
    var failures = 0;
    var id = nextId;
    var filled = occupied;
    while (filled < target && failures < maxFailures) {
      final placed = _tryPlace(board, rng, id, spec, filled, minLength: minLength);
      if (placed == null) {
        failures++;
        continue;
      }
      board = placed;
      id++;
      filled = _occupiedCount(board);
      failures = 0;
    }
    return board;
  }

  Board _fillSingles(
    Board board,
    SeededRng rng,
    CampaignSpec spec,
    int nextId,
    int occupied,
  ) {
    var id = nextId;
    var filled = occupied;
    var progressed = true;
    while (filled < spec.fillCount && progressed) {
      progressed = false;
      final empties = <GridPos>[];
      for (var r = 0; r < spec.rows; r++) {
        for (var c = 0; c < spec.cols; c++) {
          if (board.at(r, c) == null) empties.add(GridPos(r, c));
        }
      }
      rng.shuffle(empties);
      final heads = spec.blockChance >= 6
          ? _orderHeads(board, empties)
          : empties;
      for (final head in heads) {
        if (filled >= spec.fillCount) break;
        final dirs = [...Direction.values];
        rng.shuffle(dirs);
        for (final facing in dirs) {
          if (_isRim(head, spec) && _facesOffBoard(head, facing, spec)) {
            continue;
          }
          final cells = [head];
          if (!BoardEngine.pathWouldBeMovable(board, cells, facing)) continue;
          board = board.placeArrow(
            Arrow(
              id: id,
              direction: facing,
              colorIndex: id,
              cells: cells,
            ),
          );
          id++;
          filled++;
          progressed = true;
          break;
        }
      }
    }
    return board;
  }

  /// Pull leftover holes into a neighboring tail so cream gaps close.
  Board _absorbHoles(Board board, SeededRng rng) {
    var progressed = true;
    while (progressed) {
      progressed = false;
      final pieces = board.uniqueArrows.toList();
      rng.shuffle(pieces);
      for (final arrow in pieces) {
        final dirs = [...Direction.values];
        rng.shuffle(dirs);
        final extras = <GridPos>[
          for (final dir in dirs)
            GridPos(arrow.tail.row + dir.dRow, arrow.tail.col + dir.dCol),
        ];
        for (final extra in extras) {
          if (!board.inBounds(extra.row, extra.col)) continue;
          if (board.at(extra.row, extra.col) != null) continue;
          if (arrow.occupies(extra)) continue;
          final cells = [extra, ...arrow.cells];
          if (!BoardEngine.pathWouldBeMovable(board, cells, arrow.direction)) {
            continue;
          }
          final grown = Arrow(
            id: arrow.id,
            direction: arrow.direction,
            colorIndex: arrow.colorIndex,
            cells: cells,
          );
          if (grown.bendsTowardSelf) continue;
          board = board.removeAt(arrow.head.row, arrow.head.col).placeArrow(grown);
          progressed = true;
          break;
        }
        if (progressed) break;
      }
    }
    return board;
  }

  Board? _tryPlace(
    Board board,
    SeededRng rng,
    int nextId,
    CampaignSpec spec,
    int occupied, {
    required int minLength,
  }) {
    final empties = <GridPos>[];
    for (var r = 0; r < spec.rows; r++) {
      for (var c = 0; c < spec.cols; c++) {
        if (board.at(r, c) == null) empties.add(GridPos(r, c));
      }
    }
    if (empties.isEmpty) return null;
    rng.shuffle(empties);
    final heads = rng.nextInt(10) < spec.blockChance
        ? _orderHeads(board, empties)
        : empties;
    final cap = 100;
    final limit = heads.length < cap ? heads.length : cap;

    for (var i = 0; i < limit; i++) {
      final head = heads[i];
      final dirs = _orderFacings(head, spec, rng);
      for (final facing in dirs) {
        if (!BoardEngine.wouldBeMovable(board, head.row, head.col, facing)) {
          continue;
        }
        for (var attempt = 0; attempt < 3; attempt++) {
          final length = _pickLength(rng, spec, occupied, minLength);
          final turns = _pickTurns(rng, length, spec);
          final cells = _growBody(board, rng, head, facing, length, turns);
          if (cells.length < minLength) continue;
          if (!BoardEngine.pathWouldBeMovable(board, cells, facing)) continue;
          final piece = Arrow(
            id: nextId,
            direction: facing,
            colorIndex: nextId,
            cells: cells,
          );
          if (piece.bendsTowardSelf) continue;
          return board.placeArrow(piece);
        }
      }
    }
    return null;
  }

  int _pickLength(SeededRng rng, CampaignSpec spec, int occupied, int minLength) {
    final maxLen = spec.rows + spec.cols - 1;
    final remaining = spec.fillCount - occupied;
    final room = remaining < 1
        ? 1
        : (remaining < maxLen ? remaining : maxLen);
    final roll = rng.nextInt(100);
    var length = switch (spec.tier) {
      DifficultyTier.easy => _easyLength(rng, roll),
      DifficultyTier.medium => _mediumLength(rng, roll),
      DifficultyTier.hard => _hardLength(rng, roll),
      DifficultyTier.superHard => _superHardLength(rng, roll),
      DifficultyTier.nightmarish => _nightmarishLength(rng, roll),
    };
    if (length < minLength) length = minLength;
    if (length > room) length = room;
    return length < 1 ? 1 : length;
  }

  static int _easyLength(SeededRng rng, int roll) {
    if (roll < 35) return 1;
    if (roll < 65) return 2;
    if (roll < 88) return 3 + rng.nextInt(2);
    return 5 + rng.nextInt(3);
  }

  static int _mediumLength(SeededRng rng, int roll) {
    if (roll < 22) return 1;
    if (roll < 42) return 2;
    if (roll < 62) return 3 + rng.nextInt(2);
    if (roll < 80) return 5 + rng.nextInt(3);
    if (roll < 92) return 8 + rng.nextInt(3);
    return 11 + rng.nextInt(4);
  }

  static int _hardLength(SeededRng rng, int roll) {
    if (roll < 16) return 1;
    if (roll < 32) return 2;
    if (roll < 50) return 3 + rng.nextInt(2);
    if (roll < 68) return 5 + rng.nextInt(3);
    if (roll < 86) return 8 + rng.nextInt(4);
    return 12 + rng.nextInt(5);
  }

  static int _superHardLength(SeededRng rng, int roll) {
    if (roll < 12) return 1;
    if (roll < 24) return 2;
    if (roll < 40) return 3 + rng.nextInt(2);
    if (roll < 58) return 5 + rng.nextInt(3);
    if (roll < 78) return 8 + rng.nextInt(5);
    return 13 + rng.nextInt(6);
  }

  static int _nightmarishLength(SeededRng rng, int roll) {
    if (roll < 28) return 1;
    if (roll < 48) return 2;
    if (roll < 62) return 3 + rng.nextInt(2);
    if (roll < 76) return 5 + rng.nextInt(4);
    if (roll < 90) return 9 + rng.nextInt(6);
    return 15 + rng.nextInt(8);
  }

  int _pickTurns(SeededRng rng, int length, CampaignSpec spec) {
    if (length <= 2) return 0;
    final maxTurns = length - 1 < 6 ? length - 1 : 6;
    return switch (spec.tier) {
      DifficultyTier.easy => length <= 4 ? 0 : (rng.nextInt(100) < 75 ? 0 : 1),
      DifficultyTier.medium => _mixTurns(rng, maxTurns, const [20, 45, 70, 88]),
      DifficultyTier.hard => _mixTurns(rng, maxTurns, const [10, 28, 52, 74, 90]),
      DifficultyTier.superHard =>
        _mixTurns(rng, maxTurns, const [6, 20, 42, 64, 82]),
      DifficultyTier.nightmarish =>
        _mixTurns(rng, maxTurns, const [8, 22, 44, 66, 84]),
    };
  }

  static int _mixTurns(SeededRng rng, int maxTurns, List<int> cuts) {
    final roll = rng.nextInt(100);
    var turns = 0;
    for (var i = 0; i < cuts.length; i++) {
      if (roll < cuts[i]) {
        turns = i;
        break;
      }
      turns = i + 1;
    }
    if (turns > maxTurns) return maxTurns;
    return turns;
  }

  /// Walk backward from [head] so the stored path is tail → head.
  /// The first step is always opposite the facing, so the last segment
  /// points the same way as the arrow head.
  List<GridPos> _growBody(
    Board board,
    SeededRng rng,
    GridPos head,
    Direction facing,
    int length,
    int turnBudget,
  ) {
    if (length <= 1) return [head];

    final body = <GridPos>[head];
    var pos = head;
    var growDir = facing.opposite;
    var turnsLeft = turnBudget;

    final turnSteps = <int>{};
    if (turnBudget > 0 && length > 2) {
      final candidates = [for (var i = 2; i < length; i++) i];
      rng.shuffle(candidates);
      final take = turnBudget < candidates.length ? turnBudget : candidates.length;
      for (var t = 0; t < take; t++) {
        turnSteps.add(candidates[t]);
      }
    }

    for (var i = 1; i < length; i++) {
      final wantTurn = i > 1 && turnsLeft > 0 &&
          (turnSteps.contains(i) || rng.nextInt(3) != 0);
      final options = <Direction>[];
      if (wantTurn) {
        options.addAll(growDir.perpendicular);
        rng.shuffle(options);
        options.add(growDir);
      } else {
        options.add(growDir);
        if (i > 1) {
          final side = [...growDir.perpendicular];
          rng.shuffle(side);
          options.addAll(side);
        }
      }

      GridPos? next;
      Direction? used;
      var best = 99;
      for (final dir in options) {
        final candidate = GridPos(pos.row + dir.dRow, pos.col + dir.dCol);
        if (!board.inBounds(candidate.row, candidate.col)) continue;
        if (board.at(candidate.row, candidate.col) != null) continue;
        if (body.contains(candidate)) continue;
        if (_touchesBodyExcept(body, pos, candidate)) continue;
        if (_onFacingRay(head, facing, candidate)) continue;
        final proposed = [candidate, ...body.reversed];
        if (!BoardEngine.pathWouldBeMovable(board, proposed, facing)) continue;
        final score = _emptyNeighborCount(board, body, candidate);
        if (next == null || score < best) {
          next = candidate;
          used = dir;
          best = score;
        }
      }
      if (next == null || used == null) break;
      if (used != growDir) turnsLeft--;
      growDir = used;
      body.add(next);
      pos = next;
    }

    return body.reversed.toList(growable: false);
  }

  static bool _touchesBodyExcept(List<GridPos> body, GridPos allowed, GridPos candidate) {
    for (final cell in body) {
      if (cell == allowed) continue;
      final dr = (cell.row - candidate.row).abs();
      final dc = (cell.col - candidate.col).abs();
      if (dr + dc == 1) return true;
    }
    return false;
  }

  static bool _onFacingRay(GridPos head, Direction facing, GridPos candidate) {
    var r = head.row + facing.dRow;
    var c = head.col + facing.dCol;
    for (var step = 0; step < 64; step++) {
      if (r == candidate.row && c == candidate.col) return true;
      r += facing.dRow;
      c += facing.dCol;
      if (r < -1 || c < -1 || r > 80 || c > 80) break;
    }
    return false;
  }

  static int _emptyNeighborCount(Board board, List<GridPos> body, GridPos pos) {
    var count = 0;
    for (final dir in Direction.values) {
      final next = GridPos(pos.row + dir.dRow, pos.col + dir.dCol);
      if (!board.inBounds(next.row, next.col)) continue;
      if (board.at(next.row, next.col) != null) continue;
      if (body.contains(next) || next == pos) continue;
      count++;
    }
    return count;
  }

  static int _occupiedCount(Board board) {
    var count = 0;
    for (final row in board.cells) {
      for (final cell in row) {
        if (cell != null) count++;
      }
    }
    return count;
  }

  static int _maxId(Board board) {
    var max = -1;
    for (final arrow in board.uniqueArrows) {
      if (arrow.id > max) max = arrow.id;
    }
    return max;
  }

  static bool _isRim(GridPos pos, CampaignSpec spec) =>
      pos.row == 0 ||
      pos.col == 0 ||
      pos.row == spec.rows - 1 ||
      pos.col == spec.cols - 1;

  static bool _facesOffBoard(GridPos pos, Direction facing, CampaignSpec spec) {
    final next = GridPos(pos.row + facing.dRow, pos.col + facing.dCol);
    return next.row < 0 ||
        next.col < 0 ||
        next.row >= spec.rows ||
        next.col >= spec.cols;
  }

  static List<Direction> _orderFacings(
    GridPos head,
    CampaignSpec spec,
    SeededRng rng,
  ) {
    final dirs = [...Direction.values];
    rng.shuffle(dirs);
    final out = <Direction>[];
    final rest = <Direction>[];
    for (final dir in dirs) {
      if (_facesOffBoard(head, dir, spec)) {
        out.add(dir);
      } else {
        rest.add(dir);
      }
    }
    if (spec.tier == DifficultyTier.easy) return [...out, ...rest];
    if (spec.tier.index >= DifficultyTier.hard.index) {
      return [...rest, ...out];
    }
    return dirs;
  }

  static List<GridPos> _orderHeads(Board board, List<GridPos> empties) {
    final blockers = _exitLaneEmpties(board);
    if (blockers.isEmpty) return empties;
    final first = <GridPos>[];
    final rest = <GridPos>[];
    for (final pos in empties) {
      if (blockers.contains(pos)) {
        first.add(pos);
      } else {
        rest.add(pos);
      }
    }
    return [...first, ...rest];
  }

  static Set<GridPos> _exitLaneEmpties(Board board) {
    final spots = <GridPos>{};
    for (final arrow in board.uniqueArrows) {
      var r = arrow.head.row + arrow.direction.dRow;
      var c = arrow.head.col + arrow.direction.dCol;
      while (board.inBounds(r, c)) {
        if (board.at(r, c) == null) spots.add(GridPos(r, c));
        r += arrow.direction.dRow;
        c += arrow.direction.dCol;
      }
    }
    return spots;
  }
}
