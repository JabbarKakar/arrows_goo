import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme textTheme(GameColors colors) {
    final primary = colors.textPrimary;
    final secondary = colors.textSecondary;
    const figures = [FontFeature.tabularFigures()];

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 56,
        height: 0.95,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: primary,
        fontFeatures: figures,
      ),
      headlineLarge: TextStyle(
        fontSize: 40,
        height: 1.0,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        height: 1.05,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: primary,
        fontFeatures: figures,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: primary,
        fontFeatures: figures,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        height: 1.05,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: primary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.2,
        color: secondary,
      ),
    );
  }
}
