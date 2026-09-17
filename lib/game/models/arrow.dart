import 'package:meta/meta.dart';

import 'direction.dart';

@immutable
class Arrow {
  const Arrow({
    required this.id,
    required this.direction,
    required this.colorIndex,
  });

  final int id;
  final Direction direction;
  final int colorIndex;

  @override
  bool operator ==(Object other) =>
      other is Arrow &&
      other.id == id &&
      other.direction == direction &&
      other.colorIndex == colorIndex;

  @override
  int get hashCode => Object.hash(id, direction, colorIndex);

  @override
  String toString() => 'Arrow($id, ${direction.token})';
}
