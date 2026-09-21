import 'package:arrows_goo/game/engine/board_engine.dart';
import 'package:arrows_goo/game/engine/board_solver.dart';
import 'package:arrows_goo/game/engine/level_generator.dart';
import 'package:arrows_goo/game/levels/difficulty.dart';
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

  group('difficulty tiers', () {
    test('generated campaign levels shuffle all five difficulties', () {
      expect(DifficultyTier.forLevel(1), DifficultyTier.easy);
      expect(DifficultyTier.forLevel(8), DifficultyTier.easy);
      expect(DifficultyTier.easy.label, 'Easy');
      expect(DifficultyTier.nightmarish.label, 'Nightmarish');

      final tiers = [
        for (var level = 9; level <= 48; level++) DifficultyTier.forLevel(level),
      ];
      expect(tiers.toSet(), DifficultyTier.values.toSet());
      expect(
        tiers.every((tier) => tier == DifficultyTier.easy),
        isFalse,
      );
      for (var i = 0; i < tiers.length - 1; i++) {
        expect(
          tiers[i],
          isNot(tiers[i + 1]),
          reason: 'Level ${i + 9} should not match the next level',
        );
      }
    });

    test('each difficulty still builds a matching board shape', () {
      final easy = CampaignSpec.forLevel(_levelWith(DifficultyTier.easy));
      final medium = CampaignSpec.forLevel(_levelWith(DifficultyTier.medium));
      final hard = CampaignSpec.forLevel(_levelWith(DifficultyTier.hard));
      final superHard =
          CampaignSpec.forLevel(_levelWith(DifficultyTier.superHard));
      final nightmare =
          CampaignSpec.forLevel(_levelWith(DifficultyTier.nightmarish));

      expect(easy.tier, DifficultyTier.easy);
      expect(medium.tier, DifficultyTier.medium);
      expect(hard.tier, DifficultyTier.hard);
      expect(superHard.tier, DifficultyTier.superHard);
      expect(nightmare.tier, DifficultyTier.nightmarish);

      expect(easy.rows, lessThan(medium.rows));
      expect(medium.rows, lessThan(hard.rows));
      expect(hard.rows, lessThan(superHard.rows));
      expect(superHard.rows, lessThan(nightmare.rows));

      expect(easy.fillCount, lessThan(medium.fillCount));
      expect(medium.fillCount, lessThan(hard.fillCount));
      expect(hard.fillCount, lessThan(superHard.fillCount));
      expect(superHard.fillCount, lessThan(nightmare.fillCount));

      expect(easy.blockChance, lessThan(medium.blockChance));
      expect(hard.blockChance, greaterThanOrEqualTo(8));
      expect(nightmare.blockChance, greaterThanOrEqualTo(9));
      expect(
        nightmare.fillCount / (nightmare.rows * nightmare.cols),
        greaterThan(easy.fillCount / (easy.rows * easy.cols)),
      );
    });
  });

  group('LevelGenerator', () {
    test('same seed produces the same board', () {
      final spec = CampaignSpec.forLevel(9);
      final a = LevelGenerator(seed: 9).generate(spec);
      final b = LevelGenerator(seed: 9).generate(spec);
      expect(a, b);
      expect(a.rows, spec.rows);
      expect(a.cols, spec.cols);
    });

    test('easy boards are small with mixed shorts and some blocking', () {
      final level = _levelWith(DifficultyTier.easy);
      final board =
          LevelGenerator(seed: level).generate(CampaignSpec.forLevel(level));
      final arrows = board.uniqueArrows.toList();
      expect(board.rows, lessThan(18));
      expect(arrows.length, greaterThan(8));
      expect(arrows.length, lessThan(55));
      expect(arrows.any((a) => a.cells.length <= 2), isTrue);
      final free = BoardEngine.movablePositions(board).length;
      expect(free, greaterThan(0));
      expect(free, lessThan(arrows.length));
    });

    test('medium boards mix lengths and turns', () {
      final level = _levelWith(DifficultyTier.medium);
      final board =
          LevelGenerator(seed: level).generate(CampaignSpec.forLevel(level));
      final arrows = board.uniqueArrows.toList();
      expect(arrows.length, greaterThan(20));
      expect(_occupancy(board), greaterThan(0.4));
      expect(arrows.where((a) => a.cells.length <= 2).length, greaterThan(4));
      expect(arrows.any((a) => a.cells.length >= 5), isTrue);
      expect(arrows.any((a) => a.turnCount >= 1), isTrue);
      final free = BoardEngine.movablePositions(board).length;
      expect(free, greaterThan(0));
      expect(free, lessThan(arrows.length));
      expect(free, lessThan((arrows.length * 0.7).ceil()));
      for (final arrow in arrows) {
        expect(arrow.bendsTowardSelf, isFalse);
        if (arrow.cells.length < 2) continue;
        final from = arrow.cells[arrow.cells.length - 2];
        expect(arrow.head.row - from.row, arrow.direction.dRow);
        expect(arrow.head.col - from.col, arrow.direction.dCol);
      }
    });

    test('harder generated levels have more arrows and stay solvable', () {
      final easyLevel = _levelWith(DifficultyTier.easy);
      final mediumLevel = _levelWith(DifficultyTier.medium);
      final hardLevel = _levelWith(DifficultyTier.hard);
      final easy =
          LevelGenerator(seed: easyLevel).generate(CampaignSpec.forLevel(easyLevel));
      final medium = LevelGenerator(seed: mediumLevel)
          .generate(CampaignSpec.forLevel(mediumLevel));
      final hard =
          LevelGenerator(seed: hardLevel).generate(CampaignSpec.forLevel(hardLevel));
      expect(easy.uniqueArrows.length, lessThan(medium.uniqueArrows.length));
      expect(medium.uniqueArrows.length, lessThan(hard.uniqueArrows.length));
      expect(BoardSolver.isSolvable(easy), isTrue);
      expect(BoardSolver.isSolvable(medium), isTrue);
      expect(BoardSolver.isSolvable(hard), isTrue);
      final easyFree = BoardEngine.movablePositions(easy).length;
      final hardFree = BoardEngine.movablePositions(hard).length;
      final easyBlocked = easy.arrowCount - easyFree;
      final hardBlocked = hard.arrowCount - hardFree;
      expect(hardBlocked, greaterThan(easyBlocked));
      expect(hardFree / hard.arrowCount, lessThan(0.55));
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

int _levelWith(DifficultyTier tier) {
  for (var level = 9; level <= 80; level++) {
    if (DifficultyTier.forLevel(level) == tier) return level;
  }
  throw StateError('No generated level with $tier');
}
