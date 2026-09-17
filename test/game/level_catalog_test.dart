import 'package:arrows_goo/game/engine/board_solver.dart';
import 'package:arrows_goo/game/engine/level_generator.dart';
import 'package:arrows_goo/game/levels/level_catalog.dart';
import 'package:arrows_goo/game/levels/tutorial_levels.dart';
import 'package:arrows_goo/game/models/board.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tutorial JSON', () {
    test('all eight tutorial levels are solvable', () async {
      final catalog = await loadTutorialCatalog();
      expect(catalog.tutorialCount, 8);

      for (var level = 1; level <= catalog.tutorialCount; level++) {
        final board = catalog.boardFor(level);
        expect(
          BoardSolver.isSolvable(board),
          isTrue,
          reason: 'Tutorial level $level should be solvable:\n$board',
        );
      }
    });

    test('level 1 reverse solution still clears', () {
      var board = Board.parse(const [
        'L U R',
        'L D R',
        'L D R',
      ]);
      for (final pos in TutorialLevels.level1Solution) {
        expect(BoardSolver.isSolvable(board), isTrue);
        board = board.removeAt(pos.row, pos.col);
      }
      expect(board.isCleared, isTrue);
    });
  });

  group('LevelGenerator', () {
    test('same seed produces the same board', () {
      final spec = CampaignSpec.forLevel(9);
      final a = LevelGenerator(seed: 9).generate(spec);
      final b = LevelGenerator(seed: 9).generate(spec);
      expect(a, b);
      expect(a.rows, 36);
      expect(a.cols, 36);
    });

    test('generated mazes mix lengths and turns', () {
      final board = LevelGenerator(seed: 9).generate(CampaignSpec.forLevel(9));
      final arrows = board.uniqueArrows.toList();
      expect(arrows.length, greaterThan(80));
      expect(_occupancy(board), greaterThan(0.45));
      expect(arrows.any((a) => a.cells.length <= 2), isTrue);
      expect(arrows.any((a) => a.cells.length >= 6), isTrue);
      expect(arrows.any((a) => a.turnCount >= 1), isTrue);
      expect(arrows.any((a) => a.turnCount >= 2), isTrue);
      for (final arrow in arrows) {
        expect(arrow.bendsTowardSelf, isFalse);
        if (arrow.cells.length < 2) continue;
        final from = arrow.cells[arrow.cells.length - 2];
        expect(arrow.head.row - from.row, arrow.direction.dRow);
        expect(arrow.head.col - from.col, arrow.direction.dCol);
      }
    });

    test('generated campaign levels are solvable', () {
      for (final level in [9, 21]) {
        final board = LevelCatalog(tutorial: const []).boardFor(level);
        expect(
          BoardSolver.isSolvable(board),
          isTrue,
          reason: 'Generated level $level should be solvable:\n$board',
        );
        expect(board.arrowCount, greaterThan(80));
        final lengths = board.uniqueArrows.map((a) => a.cells.length).toSet();
        expect(lengths.length, greaterThan(1));
        expect(lengths.reduce((a, b) => a > b ? a : b), greaterThan(2));
      }
    });
  });
}

double _occupancy(Board board) {
  var filled = 0;
  for (final row in board.cells) {
    for (final cell in row) {
      if (cell != null) filled++;
    }
  }
  return filled / (board.rows * board.cols);
}
