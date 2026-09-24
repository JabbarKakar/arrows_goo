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
        boxShadow: primary && enabled ? AppShadows.glow(colors.accent) : null,
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
              gradient: primary
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.accent, colors.secondary],
                    )
                  : null,
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
                child: Padding(
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

  Color _fill(GameColors colors) {
    return switch (widget.variant) {
      GameButtonVariant.tonal => colors.accent.withValues(alpha: 0.12),
      _ => Colors.transparent,
    };
  }

  Border? _border(GameColors colors) {
    final color = switch (widget.variant) {
      GameButtonVariant.primary => null,
      GameButtonVariant.secondary => colors.border,
      GameButtonVariant.tonal => colors.accent.withValues(alpha: 0.28),
      GameButtonVariant.destructive => colors.error.withValues(alpha: 0.5),
    };
    if (color == null) return null;
    return Border.all(color: color);
  }
}
