import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/engine/board_engine.dart';
import '../../game/models/board.dart';
import '../../game/models/direction.dart';
import '../../game/models/grid_pos.dart';
import '../../game/session/play_state.dart';
import 'arrow_tile.dart';
import 'maze_train.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    required this.board,
    required this.onTap,
    this.sliding,
    this.onSlideComplete,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.guidancePos,
    this.hintedPos,
    this.shakingPos,
    this.shakeNonce = 0,
    this.enabled = true,
  });

  final Board board;
  final SlidingArrow? sliding;
  final ValueChanged<GridPos> onTap;
  final VoidCallback? onSlideComplete;
  final ValueChanged<GridPos>? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final GridPos? guidancePos;
  final GridPos? hintedPos;
  final GridPos? shakingPos;
  final int shakeNonce;
  final bool enabled;

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  static const _padding = 1.0;
  static const _spacing = 0.0;
  static const _slideDuration = Duration(milliseconds: 420);

  late final AnimationController _slideController;
  late final Animation<double> _slide;
  late final AnimationController _hintController;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: _slideDuration);
    _slide = CurvedAnimation(parent: _slideController, curve: Curves.easeInCubic);
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    if (widget.hintedPos != null) {
      _hintController.repeat(reverse: true);
    }
    if (widget.sliding != null) {
      _runSlide();
    }
  }

  @override
  void didUpdateWidget(covariant GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sliding != widget.sliding) {
      if (widget.sliding != null) {
        _runSlide();
      } else {
        _slideController.reset();
      }
    }
    if (oldWidget.hintedPos != widget.hintedPos) {
      if (widget.hintedPos == null) {
        _hintController
          ..stop()
          ..reset();
      } else {
        _hintController.repeat(reverse: true);
      }
    }
    if (oldWidget.shakeNonce != widget.shakeNonce && widget.shakingPos != null) {
      _shakeController.forward(from: 0);
    }
  }

  Future<void> _runSlide() async {
    final cells = widget.sliding?.arrow.cells.length ?? 1;
    _slideController.duration = Duration(
      milliseconds: (240 + cells * 42).clamp(280, 900),
    );
    await _slideController.forward(from: 0);
    if (mounted) widget.onSlideComplete?.call();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _hintController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guidancePath = widget.guidancePos == null
        ? const <GridPos>[]
        : BoardEngine.pathToEdge(
            widget.board,
            widget.guidancePos!.row,
            widget.guidancePos!.col,
          );
    final guidanceClear = widget.guidancePos != null &&
        BoardEngine.isMovablePos(widget.board, widget.guidancePos!);

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final n = widget.board.cols;
          final cellSize =
              (constraints.maxWidth - _padding * 2 - _spacing * (n - 1)) / n;
          final mazeColor = Theme.of(context).colorScheme.onSurface;

          return AnimatedBuilder(
            animation: Listenable.merge([_hintController, _shakeController]),
            builder: (context, _) {
              final shakeT = _shakeController.value;
              final shakeDx = math.sin(shakeT * math.pi * 6) * 7 * (1 - shakeT);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MazeArrowsPainter(
                        board: widget.board,
                        cellSize: cellSize,
                        mazeColor: mazeColor,
                        hideId: widget.sliding?.arrow.id,
                        hintedPos: widget.hintedPos,
                        hintPulse: _hintController.value,
                        shakingPos: widget.shakingPos,
                        shakeDx: shakeDx,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: widget.board.rows * widget.board.cols <= 32
                        ? Padding(
                            padding: const EdgeInsets.all(_padding),
                            child: Column(
                              children: [
                                for (var r = 0; r < widget.board.rows; r++) ...[
                                  if (r > 0) const SizedBox(height: _spacing),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        for (var c = 0; c < widget.board.cols; c++) ...[
                                          if (c > 0) const SizedBox(width: _spacing),
                                          Expanded(
                                            child: _HitCell(
                                              key: Key('cell_${r}_$c'),
                                              board: widget.board,
                                              row: r,
                                              col: c,
                                              enabled: widget.enabled,
                                              hinted: widget.hintedPos == GridPos(r, c),
                                              onTap: widget.onTap,
                                              onLongPressStart: widget.onLongPressStart,
                                              onLongPressEnd: widget.onLongPressEnd,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: widget.enabled
                                ? (details) {
                                    final pos = _cellAt(details.localPosition, cellSize);
                                    if (pos != null) widget.onTap(pos);
                                  }
                                : null,
                            onLongPressStart: widget.enabled &&
                                    widget.onLongPressStart != null
                                ? (details) {
                                    final pos = _cellAt(details.localPosition, cellSize);
                                    if (pos != null) widget.onLongPressStart!(pos);
                                  }
                                : null,
                            onLongPressEnd: widget.enabled &&
                                    widget.onLongPressEnd != null
                                ? (_) => widget.onLongPressEnd!()
                                : null,
                            onLongPressCancel: widget.enabled
                                ? widget.onLongPressEnd
                                : null,
                          ),
                  ),
                  if (guidancePath.isNotEmpty)
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _GuidancePainter(
                          path: guidancePath,
                          cellSize: cellSize,
                          clear: guidanceClear,
                        ),
                      ),
                    ),
                  if (widget.sliding != null)
                    _SlidingArrowLayer(
                      sliding: widget.sliding!,
                      cellSize: cellSize,
                      animation: _slide,
                      boardSize: constraints.maxWidth,
                      mazeColor: mazeColor,
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  GridPos? _cellAt(Offset local, double cellSize) {
    final col = ((local.dx - _padding) / cellSize).floor();
    final row = ((local.dy - _padding) / cellSize).floor();
    if (!widget.board.inBounds(row, col)) return null;
    return GridPos(row, col);
  }
}

class _HitCell extends StatelessWidget {
  const _HitCell({
    super.key,
    required this.board,
    required this.row,
    required this.col,
    required this.enabled,
    required this.hinted,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final Board board;
  final int row;
  final int col;
  final bool enabled;
  final bool hinted;
  final ValueChanged<GridPos> onTap;
  final ValueChanged<GridPos>? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final arrow = board.at(row, col);
    final pos = GridPos(row, col);
    Widget child = const SizedBox.expand();
    if (arrow != null) {
      child = KeyedSubtree(key: Key('arrow_${arrow.id}'), child: child);
    }
    if (hinted) {
      child = KeyedSubtree(key: const Key('hinted_cell'), child: child);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onTap(pos) : null,
      onLongPressStart: enabled && onLongPressStart != null
          ? (_) => onLongPressStart!(pos)
          : null,
      onLongPressEnd: enabled && onLongPressEnd != null
          ? (_) => onLongPressEnd!()
          : null,
      onLongPressCancel: enabled ? onLongPressEnd : null,
      child: child,
    );
  }
}

class _MazeArrowsPainter extends CustomPainter {
  const _MazeArrowsPainter({
    required this.board,
    required this.cellSize,
    required this.mazeColor,
    required this.hintPulse,
    required this.shakeDx,
    this.hideId,
    this.hintedPos,
    this.shakingPos,
  });

  final Board board;
  final double cellSize;
  final Color mazeColor;
  final int? hideId;
  final GridPos? hintedPos;
  final double hintPulse;
  final GridPos? shakingPos;
  final double shakeDx;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = MazeLine.strokeFor(cellSize);
    final hintedId = widgetHintId;
    final shakingId = widgetShakeId;
    for (final arrow in board.uniqueArrows) {
      if (arrow.id == hideId) continue;
      final points = [
        for (final pos in arrow.cells)
          MazeLine.cellCenter(
            row: pos.row,
            col: pos.col,
            cellSize: cellSize,
            padding: _GameBoardState._padding,
            spacing: _GameBoardState._spacing,
          ),
      ];
      canvas.save();
      if (shakingId == arrow.id) {
        canvas.translate(shakeDx, 0);
      }
      final hinted = hintedId == arrow.id;
      if (hinted) {
        MazeLine.paintPath(
          canvas,
          points: points,
          direction: arrow.direction,
          color: MazeLine.hintBlue.withValues(alpha: 0.35 + hintPulse * 0.45),
          stroke: 1.8 + hintPulse * 0.8,
          cellSize: cellSize,
          head: false,
        );
      }
      MazeLine.paintPath(
        canvas,
        points: points,
        direction: arrow.direction,
        color: hinted ? MazeLine.hintBlue : mazeColor,
        stroke: stroke,
        cellSize: cellSize,
      );
      canvas.restore();
    }
  }

  int? get widgetHintId =>
      hintedPos == null ? null : board.atPos(hintedPos!)?.id;

  int? get widgetShakeId =>
      shakingPos == null ? null : board.atPos(shakingPos!)?.id;

  @override
  bool shouldRepaint(covariant _MazeArrowsPainter oldDelegate) {
    return oldDelegate.board != board ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.mazeColor != mazeColor ||
        oldDelegate.hideId != hideId ||
        oldDelegate.hintedPos != hintedPos ||
        oldDelegate.hintPulse != hintPulse ||
        oldDelegate.shakingPos != shakingPos ||
        oldDelegate.shakeDx != shakeDx;
  }
}

class _GuidancePainter extends CustomPainter {
  const _GuidancePainter({
    required this.path,
    required this.cellSize,
    required this.clear,
  });

  final List<GridPos> path;
  final double cellSize;
  final bool clear;

  @override
  void paint(Canvas canvas, Size size) {
    if (path.isEmpty) return;
    final points = [
      for (final pos in path)
        MazeLine.cellCenter(
          row: pos.row,
          col: pos.col,
          cellSize: cellSize,
          padding: _GameBoardState._padding,
          spacing: _GameBoardState._spacing,
        ),
    ];
    final color = clear ? MazeLine.hintBlue : const Color(0xFFE76F51);
    MazeLine.paintPath(
      canvas,
      points: points,
      direction: path.length >= 2
          ? _dirFrom(path[path.length - 2], path.last)
          : Direction.up,
      color: color.withValues(alpha: 0.9),
      stroke: 1.0,
      cellSize: cellSize,
      head: false,
    );
  }

  static Direction _dirFrom(GridPos a, GridPos b) {
    final dr = b.row - a.row;
    final dc = b.col - a.col;
    if (dr < 0) return Direction.up;
    if (dr > 0) return Direction.down;
    if (dc < 0) return Direction.left;
    return Direction.right;
  }

  @override
  bool shouldRepaint(covariant _GuidancePainter oldDelegate) {
    return oldDelegate.clear != clear ||
        oldDelegate.cellSize != cellSize ||
        oldDelegate.path != path;
  }
}

class _SlidingArrowLayer extends StatelessWidget {
  const _SlidingArrowLayer({
    required this.sliding,
    required this.cellSize,
    required this.animation,
    required this.boardSize,
    required this.mazeColor,
  });

  final SlidingArrow sliding;
  final double cellSize;
  final Animation<double> animation;
  final double boardSize;
  final Color mazeColor;

  @override
  Widget build(BuildContext context) {
    final dir = sliding.arrow.direction;
    final facing = Offset(dir.dCol.toDouble(), dir.dRow.toDouble());
    final centers = [
      for (final pos in sliding.arrow.cells)
        MazeLine.cellCenter(
          row: pos.row,
          col: pos.col,
          cellSize: cellSize,
          padding: _GameBoardState._padding,
          spacing: _GameBoardState._spacing,
        ),
    ];
    if (centers.isEmpty) return const SizedBox.shrink();

    final extend = MazeLine.endExtension(cellSize);
    final travel = boardSize + cellSize * 2;
    Offset tail;
    if (centers.length == 1) {
      tail = centers.first - facing * extend;
    } else {
      final back = centers.first - centers[1];
      final len = back.distance;
      tail = len == 0 ? centers.first : centers.first + back / len * extend;
    }
    final tip = centers.last + facing * extend;
    final far = tip + facing * travel;
    final rail = [tail, ...centers, tip, far];
    final trainLen = MazeTrain.lengthOf([tail, ...centers, tip]);

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = animation.value;
          final points = MazeTrain.window(
            rail: rail,
            start: t * (trainLen + travel),
            length: trainLen,
          );
          if (points.isEmpty) return const SizedBox.shrink();
          return CustomPaint(
            painter: _SlidingPathPainter(
              points: points,
              direction: MazeTrain.headingOf(points, dir),
              color: mazeColor,
              stroke: MazeLine.strokeFor(cellSize),
              cellSize: cellSize,
            ),
          );
        },
      ),
    );
  }
}

class _SlidingPathPainter extends CustomPainter {
  const _SlidingPathPainter({
    required this.points,
    required this.direction,
    required this.color,
    required this.stroke,
    required this.cellSize,
  });

  final List<Offset> points;
  final Direction direction;
  final Color color;
  final double stroke;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    MazeLine.paintTrain(
      canvas,
      points: points,
      direction: direction,
      color: color,
      stroke: stroke,
      cellSize: cellSize,
    );
  }

  @override
  bool shouldRepaint(covariant _SlidingPathPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.cellSize != cellSize;
  }
}
