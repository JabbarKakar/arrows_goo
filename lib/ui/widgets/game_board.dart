import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../game/engine/board_engine.dart';
import '../../game/models/board.dart';
import '../../game/models/grid_pos.dart';
import '../../game/session/play_state.dart';
import 'arrow_palette.dart';
import 'arrow_tile.dart';

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

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  static const _padding = 12.0;
  static const _spacing = 8.0;
  static const _slideDuration = Duration(milliseconds: 360);

  late final AnimationController _slideController;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: _slideDuration);
    _slide = CurvedAnimation(parent: _slideController, curve: Curves.easeInCubic);
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
  }

  Future<void> _runSlide() async {
    await _slideController.forward(from: 0);
    if (mounted) widget.onSlideComplete?.call();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colors.outline),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final n = widget.board.cols;
            final cellSize =
                (constraints.maxWidth - _padding * 2 - _spacing * (n - 1)) / n;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Padding(
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
                                  child: _BoardCell(
                                    key: Key('cell_${r}_$c'),
                                    board: widget.board,
                                    row: r,
                                    col: c,
                                    enabled: widget.enabled,
                                    hinted: widget.hintedPos == GridPos(r, c),
                                    shaking: widget.shakingPos == GridPos(r, c),
                                    shakeNonce: widget.shakeNonce,
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
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BoardCell extends StatelessWidget {
  const _BoardCell({
    super.key,
    required this.board,
    required this.row,
    required this.col,
    required this.enabled,
    required this.hinted,
    required this.shaking,
    required this.shakeNonce,
    required this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  final Board board;
  final int row;
  final int col;
  final bool enabled;
  final bool hinted;
  final bool shaking;
  final int shakeNonce;
  final ValueChanged<GridPos> onTap;
  final ValueChanged<GridPos>? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final arrow = board.at(row, col);
    final colors = Theme.of(context).colorScheme;
    final pos = GridPos(row, col);

    Widget child = arrow == null
        ? DecoratedBox(
            decoration: BoxDecoration(
              color: colors.outline.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
          )
        : ArrowTile(
            key: Key('arrow_${arrow.id}'),
            direction: arrow.direction,
            color: ArrowPalette.of(arrow.colorIndex),
          );

    if (hinted) {
      child = _HintGlow(child: child);
    }
    if (shaking) {
      child = _ShakeCell(nonce: shakeNonce, child: child);
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
      child: hinted
          ? KeyedSubtree(key: const Key('hinted_cell'), child: SizedBox.expand(child: child))
          : SizedBox.expand(child: child),
    );
  }
}

class _HintGlow extends StatefulWidget {
  const _HintGlow({required this.child});

  final Widget child;

  @override
  State<_HintGlow> createState() => _HintGlowState();
}

class _HintGlowState extends State<_HintGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulse = 0.28 + (_controller.value * 0.42);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: primary, width: 3),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: pulse),
                blurRadius: 10 + (_controller.value * 8),
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _ShakeCell extends StatefulWidget {
  const _ShakeCell({required this.nonce, required this.child});

  final int nonce;
  final Widget child;

  @override
  State<_ShakeCell> createState() => _ShakeCellState();
}

class _ShakeCellState extends State<_ShakeCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant _ShakeCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nonce != widget.nonce) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dx = math.sin(t * math.pi * 6) * 7 * (1 - t);
        return Transform.translate(
          offset: Offset(dx, 0),
          transformHitTests: false,
          child: child,
        );
      },
      child: widget.child,
    );
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
    const padding = _GameBoardState._padding;
    const spacing = _GameBoardState._spacing;
    final fill = Paint()
      ..color = (clear ? const Color(0xFF2A9D8F) : const Color(0xFFE76F51))
          .withValues(alpha: 0.32);
    final stroke = Paint()
      ..color = clear ? const Color(0xFF2A9D8F) : const Color(0xFFE76F51)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (final pos in path) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          padding + pos.col * (cellSize + spacing),
          padding + pos.row * (cellSize + spacing),
          cellSize,
          cellSize,
        ),
        const Radius.circular(12),
      );
      canvas.drawRRect(rect, fill);
      canvas.drawRRect(rect, stroke);
    }
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
  });

  final SlidingArrow sliding;
  final double cellSize;
  final Animation<double> animation;
  final double boardSize;

  @override
  Widget build(BuildContext context) {
    const padding = _GameBoardState._padding;
    const spacing = _GameBoardState._spacing;
    final origin = Offset(
      padding + sliding.from.col * (cellSize + spacing),
      padding + sliding.from.row * (cellSize + spacing),
    );
    final dir = sliding.arrow.direction;
    final travel = boardSize + cellSize;
    final delta = Offset(dir.dCol * travel, dir.dRow * travel);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        return Positioned(
          left: origin.dx + delta.dx * t,
          top: origin.dy + delta.dy * t,
          width: cellSize,
          height: cellSize,
          child: Opacity(
            opacity: (1 - t * 0.45).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 1 - t * 0.18,
              child: child,
            ),
          ),
        );
      },
      child: ArrowTile(
        direction: sliding.arrow.direction,
        color: ArrowPalette.of(sliding.arrow.colorIndex),
      ),
    );
  }
}
