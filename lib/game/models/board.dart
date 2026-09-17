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
  }) : assert(cells.length == rows),
       assert(cells.every((row) => row.length == cols)),
       cells = List.unmodifiable(
         cells.map(List<Arrow?>.unmodifiable).toList(growable: false),
       );

  final int rows;
  final int cols;
  final List<List<Arrow?>> cells;

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
    var count = 0;
    for (final row in cells) {
      for (final cell in row) {
        if (cell != null) count++;
      }
    }
    return count;
  }

  Board removeAt(int row, int col) {
    final next = [
      for (final existing in cells) [...existing],
    ];
    next[row][col] = null;
    return Board(rows: rows, cols: cols, cells: next);
  }

  factory Board.empty(int rows, int cols) {
    return Board(
      rows: rows,
      cols: cols,
      cells: List.generate(rows, (_) => List<Arrow?>.filled(cols, null)),
    );
  }

  Board place(int row, int col, Arrow arrow) {
    final next = [
      for (final existing in cells) [...existing],
    ];
    next[row][col] = arrow;
    return Board(rows: rows, cols: cols, cells: next);
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
