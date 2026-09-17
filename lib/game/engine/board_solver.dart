import '../models/board.dart';
import '../models/grid_pos.dart';
import 'board_engine.dart';

abstract final class BoardSolver {
  /// Greedy solve: always remove the first movable arrow in row-major order.
  /// Reverse-generated boards are always solvable this way.
  static List<GridPos>? solve(Board start) {
    var board = start;
    final steps = <GridPos>[];
    while (!board.isCleared) {
      final moves = BoardEngine.movablePositions(board);
      if (moves.isEmpty) return null;
      final pos = moves.first;
      steps.add(pos);
      board = board.removeAt(pos.row, pos.col);
    }
    return steps;
  }

  static bool isSolvable(Board board) => solve(board) != null;
}
