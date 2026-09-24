import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_durations.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

enum GameButtonVariant { primary, secondary, tonal, destructive }

class GameButton extends StatefulWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = GameButtonVariant.primary,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GameButtonVariant variant;
  final bool expand;

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final enabled = widget.onPressed != null;
    final primary = widget.variant == GameButtonVariant.primary;
    final foreground = _foreground(colors);
    final radius = AppRadius.lgAll;
    final textStyle = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: foreground);

    final button = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: primary && enabled
            ? [
                BoxShadow(
                  color: colors.secondary.withValues(alpha: 0.55),
                  offset: const Offset(0, 4),
                ),
                ...AppShadows.glow(colors.accent),
              ]
            : null,
      ),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: primary ? _primaryGradient(colors) : null,
              color: primary ? null : _fill(colors),
              border: _border(colors),
            ),
            child: InkWell(
              onTap: widget.onPressed,
              onHighlightChanged: enabled
                  ? (value) {
                      if (_pressed != value) setState(() => _pressed = value);
                    }
                  : null,
              borderRadius: radius,
              splashColor: colors.accent.withValues(alpha: 0.14),
              highlightColor: colors.accent.withValues(alpha: 0.06),
              child: SizedBox(
                height: primary ? 56 : 52,
                width: widget.expand ? double.infinity : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (primary)
                      Positioned(
                        top: 1.5,
                        left: 18,
                        right: 18,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.72),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                            child: const SizedBox(height: 1.5),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: widget.expand
                            ? MainAxisSize.max
                            : MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 20, color: foreground),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          _label(textStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (enabled) return button;
    return Opacity(opacity: 0.42, child: button);
  }

  Widget _label(TextStyle? textStyle) {
    final text = Text(
      widget.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
    if (!widget.expand) return text;
    return Flexible(child: text);
  }

  Color _foreground(GameColors colors) {
    return switch (widget.variant) {
      GameButtonVariant.primary => colors.onAccent,
      GameButtonVariant.destructive => colors.error,
      GameButtonVariant.tonal => colors.accent,
      GameButtonVariant.secondary => colors.textPrimary,
    };
  }

  LinearGradient _primaryGradient(GameColors colors) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(colors.accent, Colors.white, 0.32)!,
        colors.accent,
        colors.secondary,
      ],
      stops: const [0, 0.42, 1],
    );
  }

  Color _fill(GameColors colors) {
    return switch (widget.variant) {
      GameButtonVariant.tonal => colors.accent.withValues(alpha: 0.14),
      GameButtonVariant.secondary => colors.accent.withValues(alpha: 0.06),
      _ => Colors.transparent,
    };
  }

  Border? _border(GameColors colors) {
    return switch (widget.variant) {
      GameButtonVariant.primary => Border.all(
        color: Colors.white.withValues(alpha: 0.28),
      ),
      GameButtonVariant.secondary => Border.all(
        color: colors.accent.withValues(alpha: 0.38),
      ),
      GameButtonVariant.tonal => Border.all(
        color: colors.accent.withValues(alpha: 0.45),
      ),
      GameButtonVariant.destructive => Border.all(
        color: colors.error.withValues(alpha: 0.55),
      ),
    };
  }
}
