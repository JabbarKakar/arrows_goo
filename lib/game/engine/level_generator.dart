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
  final int fillCount;

  factory CampaignSpec.forLevel(int level) {
    if (level <= 40) {
      final t = (level - 9) / 31;
      return CampaignSpec(
        rows: 5,
        cols: 5,
        fillCount: 16 + (t * 6).round(),
      );
    }
    if (level <= 80) {
      final t = (level - 41) / 39;
      return CampaignSpec(
        rows: 6,
        cols: 6,
        fillCount: 28 + (t * 5).round(),
      );
    }
    if (level <= 120) {
      final t = (level - 81) / 39;
      return CampaignSpec(
        rows: 7,
        cols: 7,
        fillCount: 38 + (t * 6).round(),
      );
    }
    if (level <= 180) {
      final t = (level - 121) / 59;
      return CampaignSpec(
        rows: 8,
        cols: 8,
        fillCount: 52 + (t * 6).round(),
      );
    }
    if (level <= 240) {
      final t = (level - 181) / 59;
      return CampaignSpec(
        rows: 9,
        cols: 9,
        fillCount: 64 + (t * 8).round(),
      );
    }
    final t = ((level - 241).clamp(0, 59)) / 59;
    return CampaignSpec(
      rows: 10,
      cols: 10,
      fillCount: 80 + (t * 10).round(),
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
    final directions = Direction.values;

    for (var n = 0; n < spec.fillCount; n++) {
      final empties = <GridPos>[];
      for (var r = 0; r < spec.rows; r++) {
        for (var c = 0; c < spec.cols; c++) {
          if (board.at(r, c) == null) empties.add(GridPos(r, c));
        }
      }
      if (empties.isEmpty) break;
      rng.shuffle(empties);

      var placed = false;
      for (final pos in empties) {
        final order = [...directions];
        rng.shuffle(order);
        for (final direction in order) {
          if (!BoardEngine.wouldBeMovable(board, pos.row, pos.col, direction)) {
            continue;
          }
          board = board.place(
            pos.row,
            pos.col,
            Arrow(
              id: nextId++,
              direction: direction,
              colorIndex: pos.row * spec.cols + pos.col,
            ),
          );
          placed = true;
          break;
        }
        if (placed) break;
      }
      if (!placed) break;
    }

    return board;
  }
}
