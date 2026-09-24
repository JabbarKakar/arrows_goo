import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'game_background.dart';

class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.maxWidth = 560,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final overlay =
        (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
            .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: colors.surface,
              systemNavigationBarIconBrightness: dark
                  ? Brightness.light
                  : Brightness.dark,
            );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: appBar,
        body: GameBackground(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
