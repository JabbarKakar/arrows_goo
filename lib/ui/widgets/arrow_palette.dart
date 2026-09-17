import 'package:flutter/material.dart';

abstract final class ArrowPalette {
  static const colors = [
    Color(0xFF2A9D8F),
    Color(0xFFE9C46A),
    Color(0xFFE76F51),
    Color(0xFF4C6EF5),
    Color(0xFF9B5DE5),
    Color(0xFFF4A261),
    Color(0xFF00BBF9),
    Color(0xFFE07A9A),
  ];

  static Color of(int index) => colors[index % colors.length];
}
