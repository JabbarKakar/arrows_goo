import 'package:flutter/material.dart';

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
