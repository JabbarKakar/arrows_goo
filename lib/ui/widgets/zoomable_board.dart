import 'package:flutter/material.dart';

class ZoomableBoard extends StatefulWidget {
  const ZoomableBoard({
    super.key,
    required this.child,
    this.resetToken,
  });

  final Widget child;
  final Object? resetToken;

  @override
  State<ZoomableBoard> createState() => _ZoomableBoardState();
}

class _ZoomableBoardState extends State<ZoomableBoard> {
  static const _minScale = 0.8;
  static const _maxScale = 4.0;
  static const _zoomStep = 1.35;

  final TransformationController _controller = TransformationController();

  @override
  void didUpdateWidget(covariant ZoomableBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetToken != widget.resetToken) {
      _controller.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoom(double factor) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final current = _controller.value.getMaxScaleOnAxis();
    final next = (current * factor).clamp(_minScale, _maxScale);
    if ((next - current).abs() < 0.001) return;
    final delta = next / current;
    final focal = Offset(box.size.width / 2, box.size.height / 2);
    final scene = _controller.toScene(focal);
    setState(() {
      _controller.value = Matrix4.copy(_controller.value)
        ..translateByDouble(scene.dx, scene.dy, 0, 1)
        ..scaleByDouble(delta, delta, delta, 1)
        ..translateByDouble(-scene.dx, -scene.dy, 0, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = _controller.value.getMaxScaleOnAxis();
    final scheme = Theme.of(context).colorScheme;

    return ClipRect(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              key: const Key('board_zoom_viewer'),
              transformationController: _controller,
              minScale: _minScale,
              maxScale: _maxScale,
              boundaryMargin: const EdgeInsets.all(120),
              clipBehavior: Clip.hardEdge,
              child: widget.child,
            ),
          ),
          Positioned(
            right: 4,
            bottom: 8,
            child: Material(
              elevation: 2,
              color: scheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    key: const Key('zoom_in_button'),
                    tooltip: 'Zoom in',
                    onPressed: scale >= _maxScale - 0.01
                        ? null
                        : () => _zoom(_zoomStep),
                    icon: const Icon(Icons.add_rounded),
                  ),
                  IconButton(
                    key: const Key('zoom_out_button'),
                    tooltip: 'Zoom out',
                    onPressed: scale <= _minScale + 0.01
                        ? null
                        : () => _zoom(1 / _zoomStep),
                    icon: const Icon(Icons.remove_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
