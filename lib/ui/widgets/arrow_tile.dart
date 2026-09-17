import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/models/direction.dart';

/// Thin orthogonal maze stroke, matching the calm line-maze look.
abstract final class MazeLine {
  static const hintBlue = Color(0xFF5BA8E8);

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

  /// One short arrow inside its own cell. Never grows into empty cells,
  /// so neighbors do not join or slide into a vacated square.
  static (Offset start, Offset end) segment({
    required int row,
    required int col,
    required Direction direction,
    required double cellSize,
    required double padding,
    required double spacing,
  }) {
    final center = cellCenter(
      row: row,
      col: col,
      cellSize: cellSize,
      padding: padding,
      spacing: spacing,
    );
    final tail = endExtension(cellSize);
    final nose = endExtension(cellSize);
    final start = center -
        Offset(direction.dCol * tail, direction.dRow * tail);
    final end = center + Offset(direction.dCol * nose, direction.dRow * nose);
    return (start, end);
  }

  static void paint(
    Canvas canvas, {
    required Offset start,
    required Offset end,
    required Direction direction,
    required Color color,
    required double stroke,
    bool head = true,
  }) {
    paintPath(
      canvas,
      points: [start, end],
      direction: direction,
      color: color,
      stroke: stroke,
      cellSize: (end - start).distance * 1.7,
      head: head,
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
      final start = center - Offset(direction.dCol * tail, direction.dRow * tail);
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
    final tip = last +
        Offset(direction.dCol * extend, direction.dRow * extend);
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

class ArrowTile extends StatelessWidget {
  const ArrowTile({
    super.key,
    required this.direction,
    required this.color,
    this.hinted = false,
    this.hintPulse = 0,
  });

  final Direction direction;
  final Color color;
  final bool hinted;
  final double hintPulse;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArrowStrokePainter(
        direction: direction,
        color: color,
        hinted: hinted,
        hintPulse: hintPulse,
      ),
    );
  }
}

/// Used when a sliding arrow is given a tight bounding box along its path.
class ArrowStrokePainter extends CustomPainter {
  const ArrowStrokePainter({
    required this.direction,
    required this.color,
    this.hinted = false,
    this.hintPulse = 0,
  });

  final Direction direction;
  final Color color;
  final bool hinted;
  final double hintPulse;

  @override
  void paint(Canvas canvas, Size size) {
    final isHorizontal =
        direction == Direction.left || direction == Direction.right;
    final along = isHorizontal ? size.width : size.height;
    final across = isHorizontal ? size.height : size.width;
    if (along <= 1 || across <= 1) return;

    final stroke = MazeLine.strokeFor(across);
    final start = Offset(size.width / 2, size.height / 2) -
        Offset(direction.dCol * along / 2, direction.dRow * along / 2);
    final end = Offset(size.width / 2, size.height / 2) +
        Offset(direction.dCol * along / 2, direction.dRow * along / 2);

    if (hinted) {
      MazeLine.paint(
        canvas,
        start: start,
        end: end,
        direction: direction,
        color: MazeLine.hintBlue.withValues(alpha: 0.35 + hintPulse * 0.4),
          stroke: stroke + 0.8 + hintPulse * 0.6,
        head: false,
      );
    }
    MazeLine.paint(
      canvas,
      start: start,
      end: end,
      direction: direction,
      color: color,
      stroke: stroke,
    );
  }

  @override
  bool shouldRepaint(covariant ArrowStrokePainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.color != color ||
        oldDelegate.hinted != hinted ||
        oldDelegate.hintPulse != hintPulse;
  }
}
