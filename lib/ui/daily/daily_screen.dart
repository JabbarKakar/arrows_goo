import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/routing/app_routes.dart';
import '../../core/storage/daily_progress.dart';
import '../../game/levels/daily_puzzle.dart';
import '../../game/session/play_session.dart';
import '../../game/session/play_state.dart';

class DailyScreen extends ConsumerWidget {
  const DailyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final id = DailyPuzzle.idFor(now);
    final completed = ref.watch(dailyProgressProvider) == id;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenge')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(
              Icons.wb_sunny_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              DailyPuzzle.labelFor(now),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              completed
                  ? 'Cleared. Come back tomorrow.'
                  : 'One shared puzzle for every player today.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(flex: 3),
            FilledButton(
              key: const Key('daily_play_button'),
              onPressed: () {
                ref.read(playConfigProvider.notifier).state = PlayConfig.daily(id);
                Navigator.pushNamed(context, AppRoutes.play);
              },
              child: Text(completed ? 'Play again' : 'Play'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
