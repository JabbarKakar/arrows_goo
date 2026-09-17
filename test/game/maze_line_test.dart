import 'package:arrows_goo/ui/widgets/arrow_tile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adjacent arrows keep a gap between one head and the next tail', () {
    const cell = 20.0;
    final reach = MazeLine.endExtension(cell);
    expect(reach, lessThan(cell * 0.4));
    expect(cell - 2 * reach, greaterThan(cell * 0.3));
  });

  test('arrow heads stay small and pointed', () {
    const cell = 10.0;
    final head = MazeLine.headLength(
      cellSize: cell,
      pathLength: MazeLine.endExtension(cell) * 2,
    );
    expect(head, greaterThanOrEqualTo(2.2));
    expect(head, lessThanOrEqualTo(2.8));
  });
}
