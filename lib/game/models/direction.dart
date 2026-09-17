import 'dart:math' as math;

enum Direction {
  up,
  down,
  left,
  right;

  int get dRow => switch (this) {
    up => -1,
    down => 1,
    left => 0,
    right => 0,
  };

  int get dCol => switch (this) {
    up => 0,
    down => 0,
    left => -1,
    right => 1,
  };

  /// Rotation for an arrow glyph drawn pointing up.
  double get radians => switch (this) {
    up => 0,
    right => math.pi / 2,
    down => math.pi,
    left => -math.pi / 2,
  };

  String get token => switch (this) {
    up => 'U',
    down => 'D',
    left => 'L',
    right => 'R',
  };

  Direction get opposite => switch (this) {
    up => down,
    down => up,
    left => right,
    right => left,
  };

  List<Direction> get perpendicular => switch (this) {
    up || down => const [left, right],
    left || right => const [up, down],
  };

  static Direction parse(String token) {
    return switch (token.toUpperCase()) {
      'U' => up,
      'D' => down,
      'L' => left,
      'R' => right,
      _ => throw FormatException('Unknown direction "$token"'),
    };
  }
}
