import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/app_routes.dart';
import '../../core/storage/campaign_progress.dart';
import '../../core/theme/app_spacing.dart';
import '../../game/levels/difficulty.dart';
import '../../game/session/play_session.dart';
import '../../game/session/play_state.dart';
import '../widgets/game_badge.dart';
import '../widgets/game_button.dart';
import '../widgets/game_caption.dart';
import '../widgets/game_logo.dart';
import '../widgets/game_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.watch(campaignProgressProvider);
    final isContinue = currentLevel > 1;

    return GameScaffold(
      maxWidth: 480,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 560;
            final content = Column(
              children: [
                if (compact)
                  const SizedBox(height: AppSpacing.xl)
                else
                  const Spacer(flex: 2),
                const GameLogo(),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Arrows Goo',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                const GameCaption('Clear the grid. One arrow at a time.'),
                if (compact)
                  const SizedBox(height: AppSpacing.xxl)
                else
                  const Spacer(flex: 3),
                GameBadge(
                  key: const Key('home_level_label'),
                  label: DifficultyTier.levelTitle(currentLevel),
                ),
                const SizedBox(height: AppSpacing.lg),
                GameButton(
                  key: const Key('play_button'),
                  expand: true,
                  icon: Icons.play_arrow_rounded,
                  label: isContinue ? 'Continue' : 'Play',
                  onPressed: () {
                    ref.read(playConfigProvider.notifier).state =
                        PlayConfig.campaign(currentLevel);
                    Navigator.pushNamed(context, AppRoutes.play);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: GameButton(
                        expand: true,
                        variant: GameButtonVariant.secondary,
                        label: 'Daily',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.daily),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GameButton(
                        expand: true,
                        variant: GameButtonVariant.secondary,
                        label: 'Settings',
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.settings),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            );

            final body = Padding(padding: AppSpacing.page, child: content);
            if (compact) return SingleChildScrollView(child: body);
            return body;
          },
        ),
      ),
    );
  }
}
