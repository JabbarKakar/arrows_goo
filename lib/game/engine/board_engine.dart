import '../models/board.dart';
import '../models/direction.dart';
import '../models/grid_pos.dart';

abstract final class BoardEngine {
  /// An arrow is movable when its head has a clear lane to the board edge
  /// in the facing direction. The body follows the rails, so side blockers
  /// on the body do not matter. Cells of the same piece do not block it.
  static bool isMovable(Board board, int row, int col) {
    final arrow = board.at(row, col);
    if (arrow == null) return false;
    return pathWouldBeMovable(board, arrow.cells, arrow.direction);
  }

  static bool isMovablePos(Board board, GridPos pos) =>
      isMovable(board, pos.row, pos.col);

  static List<GridPos> movablePositions(Board board) {
    final result = <GridPos>[];
    final seen = <int>{};
    for (var r = 0; r < board.rows; r++) {
      for (var c = 0; c < board.cols; c++) {
        final arrow = board.at(r, c);
        if (arrow == null || !seen.add(arrow.id)) continue;
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

  /// Whether a single cell facing [direction] would be free if placed.
  static bool wouldBeMovable(
    Board board,
    int row,
    int col,
    Direction direction,
  ) {
    return pathWouldBeMovable(board, [GridPos(row, col)], direction);
  }

  /// [cells] is tail → head. Only the head's facing lane must be clear.
  static bool pathWouldBeMovable(
    Board board,
    List<GridPos> cells,
    Direction direction,
  ) {
    if (cells.isEmpty) return false;
    final self = {for (final pos in cells) pos};
    final head = cells.last;
    var r = head.row + direction.dRow;
    var c = head.col + direction.dCol;
    while (board.inBounds(r, c)) {
      final here = GridPos(r, c);
      if (!self.contains(here) && board.at(r, c) != null) return false;
      r += direction.dRow;
      c += direction.dCol;
    }
    return true;
  }

  /// Body cells plus the empty lane from the head to the board edge.
  static List<GridPos> pathToEdge(Board board, int row, int col) {
    final arrow = board.at(row, col);
    if (arrow == null) return const [];

    final path = [...arrow.cells];
    var r = arrow.head.row + arrow.direction.dRow;
    var c = arrow.head.col + arrow.direction.dCol;
    while (board.inBounds(r, c)) {
      path.add(GridPos(r, c));
      r += arrow.direction.dRow;
      c += arrow.direction.dCol;
    }
    return path;
  }
}
