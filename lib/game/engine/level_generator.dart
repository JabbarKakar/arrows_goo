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
  });

  final int rows;
  final int cols;

  /// Target number of occupied cells (not piece count).
  final int fillCount;

  factory CampaignSpec.forLevel(int level) {
    if (level <= 20) {
      return const CampaignSpec(rows: 36, cols: 36, fillCount: 1230);
    }
    if (level <= 40) {
      return const CampaignSpec(rows: 42, cols: 42, fillCount: 1680);
    }
    if (level <= 80) {
      return const CampaignSpec(rows: 48, cols: 48, fillCount: 2200);
    }
    return const CampaignSpec(rows: 52, cols: 52, fillCount: 2580);
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
      maxFailures: 180,
    );
    occupied = _occupiedCount(board);
    nextId = occupied == 0 ? 0 : _maxId(board) + 1;
    board = _absorbHoles(board, rng);
    occupied = _occupiedCount(board);
    nextId = occupied == 0 ? 0 : _maxId(board) + 1;
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
      for (final head in empties) {
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
    final heads = rng.nextInt(10) < 7
        ? _orderHeads(board, empties)
        : empties;
    final cap = 100;
    final limit = heads.length < cap ? heads.length : cap;

    for (var i = 0; i < limit; i++) {
      final head = heads[i];
      final dirs = [...Direction.values];
      rng.shuffle(dirs);
      for (final facing in dirs) {
        if (!BoardEngine.wouldBeMovable(board, head.row, head.col, facing)) {
          continue;
        }
        for (var attempt = 0; attempt < 3; attempt++) {
          final length = _pickLength(rng, spec, occupied, minLength);
          final turns = _pickTurns(rng, length);
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
    int length;
    if (roll < 18) {
      length = 1;
    } else if (roll < 36) {
      length = 2;
    } else if (roll < 54) {
      length = 3 + rng.nextInt(2);
    } else if (roll < 72) {
      length = 5 + rng.nextInt(3);
    } else if (roll < 88) {
      length = 8 + rng.nextInt(4);
    } else {
      length = 12 + rng.nextInt(5);
    }
    if (length < minLength) length = minLength;
    if (length > room) length = room;
    return length < 1 ? 1 : length;
  }

  int _pickTurns(SeededRng rng, int length) {
    if (length <= 2) return 0;
    if (length == 3) return rng.nextInt(2);
    final maxTurns = length - 1 < 6 ? length - 1 : 6;
    final roll = rng.nextInt(100);
    if (roll < 14) return 0;
    if (roll < 34) return 1 > maxTurns ? maxTurns : 1;
    if (roll < 56) return 2 > maxTurns ? maxTurns : 2;
    if (roll < 76) return 3 > maxTurns ? maxTurns : 3;
    if (roll < 90) return 4 > maxTurns ? maxTurns : 4;
    return maxTurns;
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
