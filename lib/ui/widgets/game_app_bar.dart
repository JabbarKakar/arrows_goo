import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GameAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 3);

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    return AppBar(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleStyle,
      ),
      leading: leading,
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.accent.withValues(alpha: 0),
                colors.accent,
                colors.secondary,
                colors.accent.withValues(alpha: 0),
              ],
            ),
          ),
          child: const SizedBox(height: 2, width: double.infinity),
        ),
      ),
    );
  }
}
