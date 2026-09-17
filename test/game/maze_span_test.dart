import 'package:arrows_goo/game/engine/maze_span.dart';
import 'package:arrows_goo/game/models/board.dart';
import 'package:arrows_goo/game/models/direction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('span is 1 when the next cell is blocked', () {
    final board = Board.parse(const ['R L']);
    expect(MazeSpan.of(board, 0, 0), 1);
    expect(MazeSpan.of(board, 0, 1), 1);
  });

  test('span grows through empty cells', () {
    final board = Board.parse(const ['R . .']);
    expect(MazeSpan.of(board, 0, 0), 3);
    expect(MazeSpan.cells(board, 0, 0).map((p) => p.col).toList(), [0, 1, 2]);
  });

  test('ownerAt maps a corridor cell back to the arrow', () {
    final board = Board.parse(const ['R . D']);
    expect(MazeSpan.ownerAt(board, 0, 0), isNotNull);
    expect(MazeSpan.ownerAt(board, 0, 0)!.col, 0);
    expect(MazeSpan.ownerAt(board, 0, 1)!.col, 0);
    expect(MazeSpan.ownerAt(board, 0, 2)!.col, 2);
  });

  test('ofDirection still works when the origin cell is empty', () {
    final blocked = Board.parse(const ['. . L']);
    expect(MazeSpan.ofDirection(blocked, 0, 0, Direction.right), 2);

    final open = Board.parse(const ['. . .']);
    expect(MazeSpan.ofDirection(open, 0, 0, Direction.right), 3);
  });
}
