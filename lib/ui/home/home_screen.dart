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
import '../widgets/game_card.dart';
import '../widgets/game_logo.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/hud_frame.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevel = ref.watch(campaignProgressProvider);
    final isContinue = currentLevel > 1;
    final titleStyle = Theme.of(context).textTheme.headlineLarge;

    return GameScaffold(
      maxWidth: 480,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: AppSpacing.page,
                    child: Column(
                      children: [
                        const Spacer(),
                        const GameLogo(animate: true),
                        const SizedBox(height: AppSpacing.md),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Arrows Goo', style: titleStyle),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const GameCaption(
                          'Clear the grid. One arrow at a time.',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        HudFrame(
                          child: GameCard(
                            child: Column(
                              children: [
                                const HudLabel('Campaign'),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  currentLevel.toString().padLeft(2, '0'),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayLarge,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                GameBadge(
                                  key: const Key('home_level_label'),
                                  label: DifficultyTier.levelTitle(
                                    currentLevel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
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
                                icon: Icons.wb_sunny_outlined,
                                label: 'Daily',
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.daily,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: GameButton(
                                expand: true,
                                variant: GameButtonVariant.secondary,
                                icon: Icons.tune_rounded,
                                label: 'Settings',
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.settings,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
