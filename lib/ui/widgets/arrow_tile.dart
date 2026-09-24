import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/models/direction.dart';

/// Thin orthogonal maze stroke, matching the calm line-maze look.
abstract final class MazeLine {
  /// How far a stroke reaches from a cell center toward the cell edge.
  /// Stay well below 0.5 so one arrow's head never meets a neighbor's tail.
  static const endReach = 0.28;

  static double strokeFor(double cellSize) => 1.0;

  static double endExtension(double cellSize) => cellSize * endReach;

  static Offset cellCenter({
    required int row,
    required int col,
    required double cellSize,
    required double padding,
    required double spacing,
  }) {
    final step = cellSize + spacing;
    return Offset(
      padding + col * step + cellSize / 2,
      padding + row * step + cellSize / 2,
    );
  }

  static void paintPath(
    Canvas canvas, {
    required List<Offset> points,
    required Direction direction,
    required Color color,
    required double stroke,
    required double cellSize,
    bool head = true,
  }) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (points.length == 1) {
      final center = points.first;
      final tail = endExtension(cellSize);
      final nose = endExtension(cellSize);
      final start =
          center - Offset(direction.dCol * tail, direction.dRow * tail);
      final tip = center + Offset(direction.dCol * nose, direction.dRow * nose);
      canvas.drawLine(start, _retract(tip, direction, stroke * 0.55), paint);
      if (head) {
        _paintHead(
          canvas,
          tip,
          direction,
          paint,
          cellSize: cellSize,
          pathLength: (tip - start).distance,
        );
      }
      return;
    }

    final extend = endExtension(cellSize);
    final first = points.first;
    final second = points[1];
    final backDx = first.dx - second.dx;
    final backDy = first.dy - second.dy;
    final backLen = (backDx * backDx + backDy * backDy);
    final dist = math.sqrt(backLen);
    final start = dist == 0
        ? first
        : Offset(
            first.dx + backDx / dist * extend,
            first.dy + backDy / dist * extend,
          );
    final last = points.last;
    final tip = last + Offset(direction.dCol * extend, direction.dRow * extend);
    final path = Path()..moveTo(start.dx, start.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    final shaftTip = _retract(tip, direction, stroke * 0.55);
    path.lineTo(shaftTip.dx, shaftTip.dy);
    canvas.drawPath(path, paint);
    if (head) {
      _paintHead(
        canvas,
        tip,
        direction,
        paint,
        cellSize: cellSize,
        pathLength: _polyLength([start, ...points.skip(1), tip]),
      );
    }
  }

  /// Draw a train window as-is, no extra end extensions.
  static void paintTrain(
    Canvas canvas, {
    required List<Offset> points,
    required Direction direction,
    required Color color,
    required double stroke,
    required double cellSize,
  }) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (points.length == 1) {
      _paintHead(
        canvas,
        points.first,
        direction,
        paint,
        cellSize: cellSize,
        pathLength: endExtension(cellSize) * 2,
      );
      return;
    }
    final tip = points.last;
    final shaftTip = _retract(tip, direction, stroke * 0.55);
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length - 1; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.lineTo(shaftTip.dx, shaftTip.dy);
    canvas.drawPath(path, paint);
    _paintHead(
      canvas,
      tip,
      direction,
      paint,
      cellSize: cellSize,
      pathLength: _polyLength(points),
    );
  }

  static double headLength({
    required double cellSize,
    double pathLength = double.infinity,
  }) {
    var len = cellSize * 0.2;
    if (len < 2.2) return 2.2;
    if (len > 2.8) return 2.8;
    return len;
  }

  static double _polyLength(List<Offset> points) {
    var total = 0.0;
    for (var i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }

  static Offset _retract(Offset tip, Direction direction, double amount) {
    return Offset(
      tip.dx - direction.dCol * amount,
      tip.dy - direction.dRow * amount,
    );
  }

  static void _paintHead(
    Canvas canvas,
    Offset tip,
    Direction direction,
    Paint paint, {
    required double cellSize,
    required double pathLength,
  }) {
    final headLen = headLength(cellSize: cellSize, pathLength: pathLength);
    final halfW = headLen * 0.42;
    final fx = direction.dCol.toDouble();
    final fy = direction.dRow.toDouble();
    final base = Offset(tip.dx - fx * headLen, tip.dy - fy * headLen);
    final chevron = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..strokeMiterLimit = 8
      ..isAntiAlias = true;
    canvas.drawPath(
      Path()
        ..moveTo(base.dx - fy * halfW, base.dy + fx * halfW)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(base.dx + fy * halfW, base.dy - fx * halfW),
      chevron,
    );
  }
}
