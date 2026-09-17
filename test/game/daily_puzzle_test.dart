import 'package:arrows_goo/game/engine/board_solver.dart';
import 'package:arrows_goo/game/engine/level_generator.dart';
import 'package:arrows_goo/game/levels/daily_puzzle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('idFor is yyyyMMdd in local time', () {
    expect(DailyPuzzle.idFor(DateTime(2026, 9, 17)), '20260917');
    expect(DailyPuzzle.labelFor(DateTime(2026, 9, 17)), '17 Sep 2026');
  });

  test('same daily id produces the same solvable board', () {
    const id = '20260917';
    final spec = DailyPuzzle.specFor(id);
    final a = LevelGenerator(seed: DailyPuzzle.seedFor(id)).generate(spec);
    final b = LevelGenerator(seed: DailyPuzzle.seedFor(id)).generate(spec);
    expect(a, b);
    expect(BoardSolver.isSolvable(a), isTrue);
  });
}
