import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_settings.dart';
import '../../core/storage/campaign_progress.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/game_app_bar.dart';
import '../widgets/game_button.dart';
import '../widgets/game_card.dart';
import '../widgets/game_dialog.dart';
import '../widgets/game_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
    final label = Theme.of(context).textTheme.labelMedium;

    return GameScaffold(
      appBar: const GameAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        children: [
          Text('Theme', style: label),
          const SizedBox(height: AppSpacing.sm),
          GameCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selected) {
                settingsNotifier.setThemeMode(selected.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  key: const Key('sound_toggle'),
                  secondary: const Icon(Icons.volume_up_rounded),
                  title: const Text('Sound'),
                  subtitle: const Text('Whoosh, tap, and clear chime'),
                  value: settings.soundEnabled,
                  onChanged: settingsNotifier.setSoundEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  key: const Key('haptics_toggle'),
                  secondary: const Icon(Icons.vibration_rounded),
                  title: const Text('Haptics'),
                  subtitle: const Text(
                    'Light on a free slide, medium on a blocked tap',
                  ),
                  value: settings.hapticsEnabled,
                  onChanged: settingsNotifier.setHapticsEnabled,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  key: const Key('celebrations_toggle'),
                  secondary: const Icon(Icons.auto_awesome_rounded),
                  title: const Text('Celebrations'),
                  subtitle: const Text('Confetti when you clear a board'),
                  value: settings.celebrationsEnabled,
                  onChanged: settingsNotifier.setCelebrationsEnabled,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GameButton(
            key: const Key('reset_progress_button'),
            expand: true,
            variant: GameButtonVariant.destructive,
            icon: Icons.restart_alt_rounded,
            label: 'Reset campaign progress',
            onPressed: () => _confirmReset(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await GameDialog.confirm(
      context,
      title: 'Reset progress?',
      message: 'Campaign returns to Level 1. Daily completion is kept.',
      confirmLabel: 'Reset',
      confirmKey: const Key('confirm_reset_button'),
    );
    if (confirmed) {
      await ref.read(campaignProgressProvider.notifier).reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign reset to Level 1')),
        );
      }
    }
  }
}
