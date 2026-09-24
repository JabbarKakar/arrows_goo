import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

abstract final class ArrowPalette {
  static const colors = AppColors.burst;

  static Color of(int index) => colors[index % colors.length];
}
