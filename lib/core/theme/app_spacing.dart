import 'package:flutter/painting.dart';

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  static const page = EdgeInsets.symmetric(horizontal: lg);
  static const pageCompact = EdgeInsets.fromLTRB(md, sm, md, sm);
}
