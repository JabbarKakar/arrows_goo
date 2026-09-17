import 'package:arrows_goo/game/models/direction.dart';
import 'package:arrows_goo/ui/widgets/maze_train.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('window slides an L along its rails instead of translating it', () {
    const rail = [
      Offset(0, 20),
      Offset(0, 0),
      Offset(40, 0),
      Offset(80, 0),
    ];
    expect(MazeTrain.lengthOf(rail), 100);

    final parked = MazeTrain.window(rail: rail, start: 0, length: 40);
    expect(parked.first.dx, closeTo(0, 0.01));
    expect(parked.first.dy, closeTo(20, 0.01));
    expect(parked.last.dx, closeTo(20, 0.01));
    expect(parked.last.dy, closeTo(0, 0.01));

    final mid = MazeTrain.window(rail: rail, start: 20, length: 40);
    expect(mid.first.dx, closeTo(0, 0.01));
    expect(mid.first.dy, closeTo(0, 0.01));
    expect(mid.last.dx, closeTo(40, 0.01));
    expect(mid.last.dy, closeTo(0, 0.01));
    expect(MazeTrain.headingOf(mid, Direction.up), Direction.right);
  });
}
