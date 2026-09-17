import 'package:arrows_goo/game/models/direction.dart';
import 'package:arrows_goo/ui/widgets/arrow_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('arrows are hairline thin', () {
    expect(MazeLine.strokeFor(8), 1.0);
    expect(MazeLine.strokeFor(40), 1.0);
  });

  test('each arrow is drawn only inside its own cell', () {
    const cell = 40.0;
    final left = MazeLine.segment(
      row: 0,
      col: 0,
      direction: Direction.right,
      cellSize: cell,
      padding: 0,
      spacing: 0,
    );
    final right = MazeLine.segment(
      row: 0,
      col: 1,
      direction: Direction.left,
      cellSize: cell,
      padding: 0,
      spacing: 0,
    );

    expect((left.$2 - left.$1).distance, lessThan(cell));
    expect((right.$1 - left.$2).dx.abs(), greaterThan(8));
  });
}
