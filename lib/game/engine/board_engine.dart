import '../models/board.dart';
import '../models/direction.dart';
import '../models/grid_pos.dart';

abstract final class BoardEngine {
  /// An arrow is movable when every cell from the next square in its facing
  /// direction to the board edge is empty. Outward edge arrows are always free.
  static bool isMovable(Board board, int row, int col) {
    final arrow = board.at(row, col);
    if (arrow == null) return false;

    var r = row + arrow.direction.dRow;
    var c = col + arrow.direction.dCol;
    while (board.inBounds(r, c)) {
      if (board.at(r, c) != null) return false;
      r += arrow.direction.dRow;
      c += arrow.direction.dCol;
    }
    return true;
  }

  static bool isMovablePos(Board board, GridPos pos) =>
      isMovable(board, pos.row, pos.col);

  static List<GridPos> movablePositions(Board board) {
    final result = <GridPos>[];
    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        if (isMovable(board, r, c)) result.add(GridPos(r, c));
      }
    }
    return result;
  }

  static Board applyMove(Board board, int row, int col) {
    if (!isMovable(board, row, col)) {
      throw ArgumentError('Cannot move arrow at ($row, $col)');
    }
    return board.removeAt(row, col);
  }

  static Board? tryMove(Board board, int row, int col) {
    if (!isMovable(board, row, col)) return null;
    return board.removeAt(row, col);
  }

  /// Whether an arrow facing [direction] would be free if placed at [row], [col].
  static bool wouldBeMovable(
    Board board,
    int row,
    int col,
    Direction direction,
  ) {
    var r = row + direction.dRow;
    var c = col + direction.dCol;
    while (board.inBounds(r, c)) {
      if (board.at(r, c) != null) return false;
      r += direction.dRow;
      c += direction.dCol;
    }
    return true;
  }

  /// Cells from the arrow through the last in-bounds square in its facing direction.
  static List<GridPos> pathToEdge(Board board, int row, int col) {
    final arrow = board.at(row, col);
    if (arrow == null) return const [];

    final path = <GridPos>[];
    var r = row;
    var c = col;
    while (board.inBounds(r, c)) {
      path.add(GridPos(r, c));
      r += arrow.direction.dRow;
      c += arrow.direction.dCol;
    }
    return path;
  }
}
