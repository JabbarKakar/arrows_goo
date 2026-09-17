import 'dart:ui';

import '../../game/models/direction.dart';

/// Slides a polyline along its own rails, like a train, instead of dragging
/// the whole shape sideways.
abstract final class MazeTrain {
  static double lengthOf(List<Offset> rail) {
    var total = 0.0;
    for (var i = 1; i < rail.length; i++) {
      total += (rail[i] - rail[i - 1]).distance;
    }
    return total;
  }

  static Offset pointAt(List<Offset> rail, double distance) {
    if (rail.isEmpty) return Offset.zero;
    if (rail.length == 1 || distance <= 0) return rail.first;
    var remaining = distance;
    for (var i = 0; i < rail.length - 1; i++) {
      final a = rail[i];
      final b = rail[i + 1];
      final seg = (b - a).distance;
      if (seg <= 0) continue;
      if (remaining <= seg) {
        final t = remaining / seg;
        return Offset.lerp(a, b, t)!;
      }
      remaining -= seg;
    }
    return rail.last;
  }

  /// The portion of [rail] from [start] along the track for [length].
  static List<Offset> window({
    required List<Offset> rail,
    required double start,
    required double length,
  }) {
    if (rail.length < 2 || length <= 0) return const [];
    final total = lengthOf(rail);
    if (start >= total) return const [];
    final from = start < 0 ? 0.0 : start;
    final to = (start + length) > total ? total : (start + length);
    if (to <= from) return const [];

    final result = <Offset>[];
    var dist = 0.0;
    var begun = false;
    for (var i = 0; i < rail.length - 1; i++) {
      final a = rail[i];
      final b = rail[i + 1];
      final seg = (b - a).distance;
      if (seg <= 0) continue;
      final d0 = dist;
      final d1 = dist + seg;
      if (!begun && from <= d1) {
        final t = ((from - d0) / seg).clamp(0.0, 1.0);
        result.add(Offset.lerp(a, b, t)!);
        begun = true;
      }
      if (begun) {
        if (to <= d1) {
          final t = ((to - d0) / seg).clamp(0.0, 1.0);
          final end = Offset.lerp(a, b, t)!;
          if (result.isEmpty || (result.last - end).distance > 0.01) {
            result.add(end);
          }
          break;
        }
        if ((result.last - b).distance > 0.01) result.add(b);
      }
      dist = d1;
    }
    return result;
  }

  static Direction headingOf(List<Offset> points, Direction fallback) {
    if (points.length < 2) return fallback;
    final a = points[points.length - 2];
    final b = points.last;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    if (dx.abs() > dy.abs()) {
      return dx < 0 ? Direction.left : Direction.right;
    }
    if (dy == 0) return fallback;
    return dy < 0 ? Direction.up : Direction.down;
  }
}
