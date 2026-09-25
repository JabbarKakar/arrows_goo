import 'package:meta/meta.dart';

import 'arrow.dart';
import 'direction.dart';
import 'grid_pos.dart';

@immutable
class Board {
  Board({
    required this.rows,
    required this.cols,
    required List<List<Arrow?>> cells,
    List<List<bool>>? playable,
    List<List<bool>>? walls,
  }) : assert(cells.length == rows),
       assert(cells.every((row) => row.length == cols)),
       assert(playable == null || playable.length == rows),
       assert(walls == null || walls.length == rows),
       cells = List.unmodifiable(
         cells.map(List<Arrow?>.unmodifiable).toList(growable: false),
       ),
       playable = playable == null
           ? null
           : List.unmodifiable(
               playable.map(List<bool>.unmodifiable).toList(growable: false),
             ),
       walls = walls == null
           ? null
           : List.unmodifiable(
               walls.map(List<bool>.unmodifiable).toList(growable: false),
             );

  final int rows;
  final int cols;
  final List<List<Arrow?>> cells;

  /// Cells the puzzle is allowed to use. Null means the full rectangle.
  final List<List<bool>>? playable;

  /// In-bounds dividers. A lane that hits one is blocked, not an exit.
  final List<List<bool>>? walls;

  /// Parses a grid of `U D L R` tokens. `.` is empty. Tokens are whitespace-separated.
  factory Board.parse(List<String> lines) {
    final tokens = lines
        .map((line) => line.trim().split(RegExp(r'\s+')))
        .toList(growable: false);
    final rowCount = tokens.length;
    final colCount = tokens.first.length;
    var nextId = 0;
    final cells = <List<Arrow?>>[];
    for (var r = 0; r < rowCount; r++) {
      if (tokens[r].length != colCount) {
        throw FormatException('Row $r has ${tokens[r].length} cells, expected $colCount');
      }
      final row = <Arrow?>[];
      for (var c = 0; c < colCount; c++) {
        final token = tokens[r][c];
        if (token == '.') {
          row.add(null);
        } else {
          row.add(
            Arrow(
              id: nextId++,
              direction: Direction.parse(token),
              colorIndex: r * colCount + c,
              cells: [GridPos(r, c)],
            ),
          );
        }
      }
      cells.add(row);
    }
    return Board(rows: rowCount, cols: colCount, cells: cells);
  }

  bool inBounds(int row, int col) =>
      row >= 0 && row < rows && col >= 0 && col < cols;

  /// Inside the silhouette. Outside cells are open air, so an arrow escapes
  /// as soon as its lane leaves the shape.
  bool isPlayable(int row, int col) {
    if (!inBounds(row, col)) return false;
    final mask = playable;
    if (mask == null) return true;
    return mask[row][col];
  }

  /// Section divider. Arrows cannot enter or escape through it.
  bool isWall(int row, int col) {
    if (!inBounds(row, col)) return false;
    final mask = walls;
    if (mask == null) return false;
    return mask[row][col];
  }

  Arrow? at(int row, int col) {
    if (!inBounds(row, col)) return null;
    return cells[row][col];
  }

  Arrow? atPos(GridPos pos) => at(pos.row, pos.col);

  bool get isCleared {
    for (final row in cells) {
      for (final cell in row) {
        if (cell != null) return false;
      }
    }
    return true;
  }

  int get arrowCount {
    final ids = <int>{};
    for (final row in cells) {
      for (final cell in row) {
        if (cell != null) ids.add(cell.id);
      }
    }
    return ids.length;
  }

  Iterable<Arrow> get uniqueArrows sync* {
    final seen = <int>{};
    for (final row in cells) {
      for (final cell in row) {
        if (cell != null && seen.add(cell.id)) yield cell;
      }
    }
  }

  Board removeAt(int row, int col) {
    final arrow = at(row, col);
    if (arrow == null) return this;
    final next = [
      for (final existing in cells) [...existing],
    ];
    for (final pos in arrow.cells) {
      if (inBounds(pos.row, pos.col) && next[pos.row][pos.col]?.id == arrow.id) {
        next[pos.row][pos.col] = null;
      }
    }
    return Board(
      rows: rows,
      cols: cols,
      cells: next,
      playable: playable,
      walls: walls,
    );
  }

  factory Board.empty(int rows, int cols) {
    return Board(
      rows: rows,
      cols: cols,
      cells: List.generate(rows, (_) => List<Arrow?>.filled(cols, null)),
    );
  }

  Board place(int row, int col, Arrow arrow) {
    final piece = arrow.cells.isEmpty
        ? Arrow(
            id: arrow.id,
            direction: arrow.direction,
            colorIndex: arrow.colorIndex,
            cells: [GridPos(row, col)],
          )
        : arrow;
    return placeArrow(piece);
  }

  Board placeArrow(Arrow arrow) {
    final next = [
      for (final existing in cells) [...existing],
    ];
    for (final pos in arrow.cells) {
      next[pos.row][pos.col] = arrow;
    }
    return Board(
      rows: rows,
      cols: cols,
      cells: next,
      playable: playable,
      walls: walls,
    );
  }

  factory Board.masked(
    int rows,
    int cols,
    bool Function(int row, int col) allow, {
    bool Function(int row, int col)? wall,
  }) {
    final playable = List<List<bool>>.generate(
      rows,
      (r) => List<bool>.generate(cols, (c) => allow(r, c)),
    );
    final walls = wall == null
        ? null
        : List<List<bool>>.generate(
            rows,
            (r) => List<bool>.generate(
              cols,
              (c) => wall(r, c) && !playable[r][c],
            ),
          );
    return Board(
      rows: rows,
      cols: cols,
      cells: List.generate(rows, (_) => List<Arrow?>.filled(cols, null)),
      playable: playable,
      walls: walls,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! Board || other.rows != rows || other.cols != cols) {
      return false;
    }
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (other.cells[r][c] != cells[r][c]) return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(rows, cols, Object.hashAll(cells.expand((r) => r)));

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var r = 0; r < rows; r++) {
      if (r > 0) buffer.writeln();
      for (var c = 0; c < cols; c++) {
        if (c > 0) buffer.write(' ');
        buffer.write(cells[r][c]?.direction.token ?? '.');
      }
    }
    return buffer.toString();
  }
}
