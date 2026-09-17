import '../models/board.dart';
import '../models/direction.dart';
import '../models/grid_pos.dart';

/// Visual length of an arrow: its cell plus empty cells ahead until a block or edge.
abstract final class MazeSpan {
  static int of(Board board, int row, int col) {
    final arrow = board.at(row, col);
    if (arrow == null) return 0;
    return ofDirection(board, row, col, arrow.direction);
  }

  static int ofDirection(
    Board board,
    int row,
    int col,
    Direction direction,
  ) {
    var span = 1;
    var r = row + direction.dRow;
    var c = col + direction.dCol;
    while (board.inBounds(r, c) && board.at(r, c) == null) {
      span++;
      r += direction.dRow;
      c += direction.dCol;
    }
    return span;
  }

  static List<GridPos> cells(Board board, int row, int col) {
    final arrow = board.at(row, col);
    if (arrow == null) return const [];
    final span = of(board, row, col);
    return [
      for (var i = 0; i < span; i++)
        GridPos(row + arrow.direction.dRow * i, col + arrow.direction.dCol * i),
    ];
  }

  /// Occupied cell, or the arrow whose maze stroke covers this empty cell.
  static GridPos? ownerAt(Board board, int row, int col) {
    if (!board.inBounds(row, col)) return null;
    if (board.at(row, col) != null) return GridPos(row, col);

    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        if (board.at(r, c) == null) continue;
        for (final cell in cells(board, r, c)) {
          if (cell.row == row && cell.col == col) {
            return GridPos(r, c);
          }
        }
      }
    }
    return null;
  }
}
