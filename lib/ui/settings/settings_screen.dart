import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_settings.dart';
import '../../core/storage/campaign_progress.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Text('Theme', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
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
          const SizedBox(height: 24),
          SwitchListTile(
            key: const Key('sound_toggle'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Sound'),
            subtitle: const Text('Whoosh, tap, and clear chime'),
            value: settings.soundEnabled,
            onChanged: settingsNotifier.setSoundEnabled,
          ),
          SwitchListTile(
            key: const Key('haptics_toggle'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Haptics'),
            subtitle: const Text('Light on a free slide, medium on a blocked tap'),
            value: settings.hapticsEnabled,
            onChanged: settingsNotifier.setHapticsEnabled,
          ),
          SwitchListTile(
            key: const Key('celebrations_toggle'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Celebrations'),
            subtitle: const Text('Confetti when you clear a board'),
            value: settings.celebrationsEnabled,
            onChanged: settingsNotifier.setCelebrationsEnabled,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            key: const Key('reset_progress_button'),
            onPressed: () => _confirmReset(context, ref),
            child: const Text('Reset campaign progress'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text('Campaign returns to Level 1. Daily completion is kept.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              key: const Key('confirm_reset_button'),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(campaignProgressProvider.notifier).reset();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Campaign reset to Level 1')),
        );
      }
    }
  }
}
