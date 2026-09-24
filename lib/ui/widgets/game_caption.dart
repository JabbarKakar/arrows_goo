import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GameCaption extends StatelessWidget {
  const GameCaption(
    this.text, {
    super.key,
    this.align = TextAlign.center,
    this.color,
    this.strong = false,
  });

  final String text;
  final TextAlign align;
  final Color? color;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final base = strong ? theme.titleMedium : theme.bodyLarge;
    return Text(
      text,
      textAlign: align,
      style: color == null ? base : base?.copyWith(color: color),
    );
  }
}

class HudLabel extends StatelessWidget {
  const HudLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color ?? colors.accent,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
      ),
    );
  }
}
