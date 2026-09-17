import 'package:arrows_goo/game/engine/board_engine.dart';
import 'package:arrows_goo/game/levels/tutorial_levels.dart';
import 'package:arrows_goo/game/models/arrow.dart';
import 'package:arrows_goo/game/models/board.dart';
import 'package:arrows_goo/game/models/direction.dart';
import 'package:arrows_goo/game/models/grid_pos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoardEngine.isMovable', () {
    test('outward edge arrows are always movable', () {
      final board = Board.parse(const [
        'L . R',
        '. D .',
        'D . .',
      ]);

      expect(BoardEngine.isMovable(board, 0, 0), isTrue);
      expect(BoardEngine.isMovable(board, 0, 2), isTrue);
      expect(BoardEngine.isMovable(board, 1, 1), isTrue);
      expect(BoardEngine.isMovable(board, 2, 0), isTrue);
    });

    test('empty cells are not movable', () {
      final board = Board.parse(const [
        'L .',
        '. R',
      ]);

      expect(BoardEngine.isMovable(board, 0, 1), isFalse);
      expect(BoardEngine.isMovable(board, 1, 0), isFalse);
    });

    test('an arrow is blocked when another occupies its path', () {
      final board = Board.parse(const [
        'R R',
        'U .',
      ]);

      expect(BoardEngine.isMovable(board, 0, 0), isFalse);
      expect(BoardEngine.isMovable(board, 0, 1), isTrue);
      expect(BoardEngine.isMovable(board, 1, 0), isFalse);
    });

    test('empty cells on the path do not block', () {
      final board = Board.parse(const [
        'R . .',
        '. . L',
      ]);

      expect(BoardEngine.isMovable(board, 0, 0), isTrue);
      expect(BoardEngine.isMovable(board, 1, 2), isTrue);
    });

    test('tutorial 4x4 starts with blocked interior and free edges', () {
      final board = TutorialLevels.fourByFour;

      expect(BoardEngine.isMovable(board, 0, 0), isTrue);
      expect(BoardEngine.isMovable(board, 3, 3), isTrue);
      expect(BoardEngine.isMovable(board, 1, 1), isFalse);
      expect(BoardEngine.isMovable(board, 2, 2), isFalse);
    });
  });

  group('BoardEngine.applyMove', () {
    test('removes a movable arrow', () {
      final board = Board.parse(const ['R R']);
      final next = BoardEngine.applyMove(board, 0, 1);

      expect(next.at(0, 1), isNull);
      expect(next.at(0, 0), isNotNull);
      expect(BoardEngine.isMovable(next, 0, 0), isTrue);
    });

    test('throws when the arrow is blocked', () {
      final board = Board.parse(const ['R R']);
      expect(() => BoardEngine.applyMove(board, 0, 0), throwsArgumentError);
    });

    test('tryMove returns null when blocked', () {
      final board = Board.parse(const ['R R']);
      expect(BoardEngine.tryMove(board, 0, 0), isNull);
    });
  });

  group('tutorial 4x4 solution', () {
    test('known sequence clears the board', () {
      var board = TutorialLevels.fourByFour;
      expect(board.arrowCount, 16);

      for (final pos in TutorialLevels.fourByFourSolution) {
        expect(
          BoardEngine.isMovablePos(board, pos),
          isTrue,
          reason: 'Expected $pos to be movable on:\n$board',
        );
        board = BoardEngine.applyMove(board, pos.row, pos.col);
      }

      expect(board.isCleared, isTrue);
    });

    test('a wrong early interior tap is not part of a legal start', () {
      final board = TutorialLevels.fourByFour;
      expect(BoardEngine.isMovable(board, 1, 1), isFalse);
      expect(BoardEngine.tryMove(board, 1, 1), isNull);
    });

    test('removing an edge arrow can unblock another', () {
      var board = TutorialLevels.fourByFour;
      expect(BoardEngine.isMovable(board, 3, 1), isFalse);

      board = BoardEngine.applyMove(board, 3, 3);
      board = BoardEngine.applyMove(board, 3, 2);

      expect(BoardEngine.isMovable(board, 3, 1), isTrue);
    });
  });

  group('BoardEngine.pathToEdge', () {
    test('includes the arrow and every cell to the edge', () {
      final board = Board.parse(const [
        'R . .',
        '. . .',
      ]);
      expect(
        BoardEngine.pathToEdge(board, 0, 0),
        [const GridPos(0, 0), const GridPos(0, 1), const GridPos(0, 2)],
      );
    });

    test('returns empty for an empty cell', () {
      final board = Board.parse(const ['. R']);
      expect(BoardEngine.pathToEdge(board, 0, 0), isEmpty);
    });
  });

  group('GridPos', () {
    test('equality', () {
      expect(const GridPos(1, 2), const GridPos(1, 2));
      expect(const GridPos(1, 2), isNot(const GridPos(2, 1)));
    });
  });

  test('L-shaped arrow is one piece and unblocks together', () {
    var board = Board.empty(3, 3).placeArrow(
      Arrow(
        id: 0,
        direction: Direction.right,
        colorIndex: 0,
        cells: const [GridPos(0, 0), GridPos(1, 0), GridPos(1, 1)],
      ),
    );
    expect(board.arrowCount, 1);
    expect(board.at(0, 0)!.id, board.at(1, 1)!.id);
    expect(board.at(0, 0)!.turnCount, 1);
    expect(BoardEngine.isMovable(board, 0, 0), isTrue);

    board = board.removeAt(1, 1);
    expect(board.arrowCount, 0);
    expect(board.isCleared, isTrue);
  });

  test('only the head lane must be clear, not the body', () {
    var board = Board.empty(3, 3).placeArrow(
      Arrow(
        id: 0,
        direction: Direction.right,
        colorIndex: 0,
        cells: const [GridPos(0, 0), GridPos(1, 0), GridPos(1, 1)],
      ),
    );
    board = board.placeArrow(
      Arrow(
        id: 1,
        direction: Direction.up,
        colorIndex: 1,
        cells: const [GridPos(0, 1)],
      ),
    );

    // Body cell (0,0) is blocked to the right by (0,1), but the head at
    // (1,1) faces an empty lane, so the L can still leave.
    expect(BoardEngine.isMovable(board, 1, 1), isTrue);
    expect(BoardEngine.isMovable(board, 0, 0), isTrue);
    expect(BoardEngine.isMovable(board, 0, 1), isTrue);
  });
}
