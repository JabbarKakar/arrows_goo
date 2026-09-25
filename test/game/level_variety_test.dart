import 'package:arrows_goo/game/engine/board_engine.dart';
import 'package:arrows_goo/game/engine/level_generator.dart';
import 'package:arrows_goo/game/levels/difficulty.dart';
import 'package:arrows_goo/game/levels/level_shape.dart';
import 'package:arrows_goo/game/models/arrow.dart';
import 'package:arrows_goo/game/models/board.dart';
import 'package:arrows_goo/game/models/direction.dart';
import 'package:arrows_goo/game/models/grid_pos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('campaign levels vary shape and palette, and neighbors differ', () {
    final shapes = <LevelShape>[];
    final palettes = <LevelPalette>[];
    for (var level = 9; level <= 24; level++) {
      shapes.add(LevelShape.forLevel(level));
      palettes.add(LevelPalette.forLevel(level));
      if (level > 9) {
        expect(shapes.last, isNot(shapes[shapes.length - 2]));
        expect(palettes.last, isNot(palettes[palettes.length - 2]));
      }
    }
    expect(shapes.toSet().length, greaterThan(4));
    expect(palettes.toSet(), containsAll(LevelPalette.values));
  });

  test('a shaped board only places arrows inside the silhouette', () {
    final level = _levelWith(LevelShape.heart);
    final spec = CampaignSpec.forLevel(level);
    expect(spec.shape, LevelShape.heart);
    final board = LevelGenerator(seed: level).generate(spec);
    expect(board.playable, isNotNull);
    expect(board.arrowCount, greaterThan(8));
    for (final arrow in board.uniqueArrows) {
      for (final cell in arrow.cells) {
        expect(board.isPlayable(cell.row, cell.col), isTrue);
      }
    }
    final colors = board.uniqueArrows.map((arrow) => arrow.colorIndex).toSet();
    expect(colors, isNotEmpty);
  });

  test('panel sections share one board and arrows stay inside their square', () {
    final level = _levelWith(LevelShape.panels);
    final spec = CampaignSpec.forLevel(level);
    final board = LevelGenerator(seed: level).generate(spec);
    expect(board.walls, isNotNull);
    expect(board.arrowCount, greaterThan(8));

    for (final arrow in board.uniqueArrows) {
      for (final cell in arrow.cells) {
        expect(board.isWall(cell.row, cell.col), isFalse);
        expect(board.isPlayable(cell.row, cell.col), isTrue);
      }
      expect(
        _facesAnotherSection(board, arrow),
        isFalse,
        reason: 'arrow ${arrow.id} crosses a section wall',
      );
    }

    final sample = Board.masked(
      8,
      8,
      (row, col) => LevelShape.panels.contains(row, col, 8, 8),
      wall: (row, col) => LevelShape.panels.separates(row, col, 8, 8),
    );
    final towardGap = sample.placeArrow(
      Arrow(
        id: 1,
        direction: Direction.right,
        colorIndex: 0,
        cells: const [GridPos(0, 2)],
      ),
    );
    expect(BoardEngine.isMovable(towardGap, 0, 2), isFalse);

    final outward = sample.placeArrow(
      Arrow(
        id: 2,
        direction: Direction.up,
        colorIndex: 0,
        cells: const [GridPos(0, 0)],
      ),
    );
    expect(BoardEngine.isMovable(outward, 0, 0), isTrue);
  });

  test('harder tiers have a shorter clock than easy', () {
    expect(
      DifficultyTier.easy.timeLimitSeconds,
      greaterThan(DifficultyTier.superHard.timeLimitSeconds),
    );
    expect(
      DifficultyTier.superHard.timeLimitSeconds,
      greaterThan(DifficultyTier.nightmarish.timeLimitSeconds),
    );
  });
}

bool _facesAnotherSection(Board board, Arrow arrow) {
  var r = arrow.head.row + arrow.direction.dRow;
  var c = arrow.head.col + arrow.direction.dCol;
  while (board.inBounds(r, c)) {
    if (board.isWall(r, c)) return true;
    if (!board.isPlayable(r, c)) return false;
    r += arrow.direction.dRow;
    c += arrow.direction.dCol;
  }
  return false;
}

int _levelWith(LevelShape shape) {
  for (var level = 9; level <= 40; level++) {
    if (LevelShape.forLevel(level) == shape) return level;
  }
  throw StateError('No level with $shape');
}
