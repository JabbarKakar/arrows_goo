import '../models/board.dart';
import '../models/grid_pos.dart';

/// Known solutions and fixtures used by tests.
abstract final class TutorialLevels {
  static Board get fourByFour => Board.parse(const [
    'L U U R',
    'L R D R',
    'L R D D',
    'L R D R',
  ]);

  /// Reverse of placement order for the original 4x4 fixture.
  static const List<GridPos> fourByFourSolution = [
    GridPos(3, 3),
    GridPos(3, 2),
    GridPos(3, 1),
    GridPos(3, 0),
    GridPos(2, 3),
    GridPos(2, 2),
    GridPos(2, 1),
    GridPos(2, 0),
    GridPos(1, 3),
    GridPos(1, 2),
    GridPos(1, 1),
    GridPos(1, 0),
    GridPos(0, 3),
    GridPos(0, 2),
    GridPos(0, 1),
    GridPos(0, 0),
  ];

  /// Reverse placement order for tutorial JSON level 1.
  static const List<GridPos> level1Solution = [
    GridPos(2, 2),
    GridPos(2, 1),
    GridPos(2, 0),
    GridPos(1, 2),
    GridPos(1, 1),
    GridPos(1, 0),
    GridPos(0, 2),
    GridPos(0, 1),
    GridPos(0, 0),
  ];
}
