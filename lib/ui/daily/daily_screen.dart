import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/routing/app_routes.dart';
import '../../core/storage/daily_progress.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../game/levels/daily_puzzle.dart';
import '../../game/session/play_session.dart';
import '../../game/session/play_state.dart';
import '../widgets/game_app_bar.dart';
import '../widgets/game_button.dart';
import '../widgets/game_caption.dart';
import '../widgets/game_card.dart';
import '../widgets/game_logo.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/hud_frame.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final id = DailyPuzzle.idFor(now);
    final completed = ref.watch(dailyProgressProvider) == id;
    final colors = GameColors.of(context);

    return GameScaffold(
      maxWidth: 480,
      appBar: const GameAppBar(title: 'Daily Challenge'),
      body: SafeArea(
        top: false,
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
                        const GameLogo(icon: Icons.wb_sunny_outlined, size: 72),
                        const SizedBox(height: AppSpacing.lg),
                        HudFrame(
                          child: GameCard(
                            child: Column(
                              children: [
                                HudLabel(
                                  completed ? 'Cleared' : 'Today',
                                  color: completed ? colors.success : null,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  DailyPuzzle.labelFor(now),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                GameCaption(
                                  completed
                                      ? 'Cleared. Come back tomorrow.'
                                      : 'One shared puzzle for every player today.',
                                  color: completed ? colors.success : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        GameButton(
                          key: const Key('daily_play_button'),
                          expand: true,
                          icon: Icons.play_arrow_rounded,
                          label: completed ? 'Play again' : 'Play',
                          onPressed: () {
                            ref.read(playConfigProvider.notifier).state =
                                PlayConfig.daily(id);
                            Navigator.pushNamed(context, AppRoutes.play);
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
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
