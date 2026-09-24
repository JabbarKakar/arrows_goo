import 'dart:ui';

import 'package:flutter/painting.dart';

abstract final class AppShadows {
  static List<BoxShadow> card(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: dark ? 0.32 : 0.06),
        blurRadius: dark ? 22 : 18,
        offset: const Offset(0, 10),
      ),
    ];
  }

  static List<BoxShadow> glow(Color color) {
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.38),
        blurRadius: 22,
        spreadRadius: -6,
        offset: const Offset(0, 8),
      ),
    ];
  }
}
