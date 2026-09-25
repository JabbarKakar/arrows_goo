import 'dart:math' as math;

import '../models/grid_pos.dart';

/// How a campaign board is colored. Original treatments, not a copy of
/// any store listing.
enum LevelPalette {
  single,
  duo,
  rainbow,
  regions;

  static LevelPalette forLevel(int level) {
    if (level <= 8) return single;
    const pool = [
      single,
      duo,
      rainbow,
      regions,
      single,
      rainbow,
      duo,
      regions,
    ];
    return _pick(level, 41, pool);
  }

  int colorFor({
    required int id,
    required GridPos head,
    required int rows,
    required int cols,
    required int base,
  }) {
    return switch (this) {
      single => base,
      duo => base + (id.isEven ? 0 : 4),
      rainbow => id,
      regions =>
        base + (head.row * 3 ~/ math.max(1, rows)) * 2 + (head.col * 2 ~/ math.max(1, cols)),
    };
  }
}

/// Silhouette the arrows are allowed to occupy. The rectangle around it
/// stays empty so the puzzle reads as a shape, a frame, or separate islands.
enum LevelShape {
  block,
  diamond,
  disc,
  heart,
  triangle,
  ring,
  columns,
  panels,
  arch;

  /// Rough share of the square the silhouette covers, used to size the grid.
  double get fill => switch (this) {
        block => 1,
        diamond => 0.52,
        disc => 0.72,
        heart => 0.48,
        triangle => 0.46,
        ring => 0.5,
        columns => 0.72,
        panels => 0.84,
        arch => 0.58,
      };

  static LevelShape forLevel(int level) {
    if (level <= 8) return block;
    const pool = [
      block,
      diamond,
      disc,
      heart,
      triangle,
      ring,
      columns,
      panels,
      arch,
    ];
    return _pick(level, 17, pool);
  }

  /// True for the divider between sections. Those cells block a lane.
  bool separates(int row, int col, int rows, int cols) {
    if (row < 0 || col < 0 || row >= rows || col >= cols) return false;
    return switch (this) {
      panels || columns => !contains(row, col, rows, cols),
      _ => false,
    };
  }

  bool contains(int row, int col, int rows, int cols) {
    if (row < 0 || col < 0 || row >= rows || col >= cols) return false;
    final nx = (col + 0.5) / cols;
    final ny = (row + 0.5) / rows;
    return switch (this) {
      block => true,
      diamond => (nx - 0.5).abs() + (ny - 0.5).abs() <= 0.46,
      disc => _disc(nx, ny, 0.46),
      heart => _heart(nx, ny),
      triangle => _triangle(nx, ny),
      ring => _ring(row, col, rows, cols),
      columns => _columns(col, cols),
      panels => _panels(row, col, rows, cols),
      arch => _arch(nx, ny),
    };
  }

  static bool _disc(double nx, double ny, double radius) {
    final dx = nx - 0.5;
    final dy = ny - 0.5;
    return dx * dx + dy * dy <= radius * radius;
  }

  static bool _heart(double nx, double ny) {
    final x = (nx - 0.5) * 2.15;
    final y = (0.42 - ny) * 2.15;
    final a = x * x + y * y - 1;
    return a * a * a - x * x * y * y * y <= 0;
  }

  static bool _triangle(double nx, double ny) {
    if (ny < 0.08 || ny > 0.92) return false;
    final half = 0.06 + (ny - 0.08) / 0.84 * 0.4;
    return (nx - 0.5).abs() <= half;
  }

  static bool _ring(int row, int col, int rows, int cols) {
    final margin = math.max(1, (math.min(rows, cols) * 0.06).round());
    final hole = math.max(margin + 2, (math.min(rows, cols) * 0.28).round());
    final inside =
        row >= margin && row < rows - margin && col >= margin && col < cols - margin;
    final hollow =
        row >= hole && row < rows - hole && col >= hole && col < cols - hole;
    return inside && !hollow;
  }

  static bool _columns(int col, int cols) {
    final gap = math.max(1, cols ~/ 11);
    final left = (cols - gap) ~/ 2;
    return col < left || col >= left + gap;
  }

  static bool _panels(int row, int col, int rows, int cols) {
    // Two cells of wall, so the four squares sit together as one board.
    const band = 1;
    final midR = rows ~/ 2;
    final midC = cols ~/ 2;
    final top = row < midR - band;
    final bottom = row >= midR + band;
    final left = col < midC - band;
    final right = col >= midC + band;
    return (top || bottom) && (left || right);
  }

  static bool _arch(double nx, double ny) {
    if (ny >= 0.48 && ny <= 0.9 && nx >= 0.14 && nx <= 0.86) return true;
    if (ny > 0.48) return false;
    final dx = (nx - 0.5) / 0.36;
    final dy = (ny - 0.48) / 0.4;
    return dx * dx + dy * dy <= 1;
  }
}

T _pick<T>(int level, int salt, List<T> pool) {
  T? previous;
  var current = pool.first;
  for (var i = 9; i <= level; i++) {
    var state = (i * 1103515245 + salt * 92821) & 0x7fffffff;
    int nextInt(int max) {
      state = (state * 1103515245 + 12345) & 0x7fffffff;
      return state % max;
    }

    final items = [...pool];
    for (var pass = 0; pass < 2; pass++) {
      for (var n = items.length - 1; n > 0; n--) {
        final j = nextInt(n + 1);
        final tmp = items[n];
        items[n] = items[j];
        items[j] = tmp;
      }
    }
    current = items.firstWhere((item) => item != previous, orElse: () => items.first);
    previous = current;
  }
  return current;
}
