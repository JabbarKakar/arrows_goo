import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routing/app_routes.dart';
import '../../core/storage/campaign_progress.dart';
import '../../game/levels/difficulty.dart';
import '../../game/session/play_session.dart';
import '../../game/session/play_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final currentLevel = ref.watch(campaignProgressProvider);
    final isContinue = currentLevel > 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.north_east_rounded,
                  size: 44,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Arrows Goo',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Clear the grid. One arrow at a time.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(flex: 3),
              FilledButton(
                key: const Key('play_button'),
                onPressed: () {
                  ref.read(playConfigProvider.notifier).state =
                      PlayConfig.campaign(currentLevel);
                  Navigator.pushNamed(context, AppRoutes.play);
                },
                child: Text(isContinue ? 'Continue' : 'Play'),
              ),
              const SizedBox(height: 10),
              Text(
                'Level $currentLevel · ${DifficultyTier.forLevel(currentLevel).label}',
                key: const Key('home_level_label'),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.daily),
                      child: const Text('Daily'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.settings),
                      child: const Text('Settings'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
