import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/app_settings.dart';
import '../../core/storage/campaign_progress.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/game_app_bar.dart';
import '../widgets/game_button.dart';
import '../widgets/game_caption.dart';
import '../widgets/game_card.dart';
import '../widgets/game_dialog.dart';
import '../widgets/game_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);
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
          const HudLabel('Theme'),
          const SizedBox(height: AppSpacing.sm),
          GameCard(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                for (final option in _themeOptions) ...[
                  if (option != _themeOptions.first)
                    const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _ThemeChip(
                      label: option.label,
                      selected: settings.themeMode == option.mode,
                      onTap: () => settingsNotifier.setThemeMode(option.mode),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GameCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingRow(
                  switchKey: const Key('sound_toggle'),
                  icon: Icons.volume_up_rounded,
                  title: 'Sound',
                  subtitle: 'Whoosh, tap, and clear chime',
                  value: settings.soundEnabled,
                  onChanged: settingsNotifier.setSoundEnabled,
                ),
                const _SettingDivider(),
                _SettingRow(
                  switchKey: const Key('haptics_toggle'),
                  icon: Icons.vibration_rounded,
                  title: 'Haptics',
                  subtitle: 'Light on a free slide, medium on a blocked tap',
                  value: settings.hapticsEnabled,
                  onChanged: settingsNotifier.setHapticsEnabled,
                ),
                const _SettingDivider(),
                _SettingRow(
                  switchKey: const Key('celebrations_toggle'),
                  icon: Icons.auto_awesome_rounded,
                  title: 'Celebrations',
                  subtitle: 'Confetti when you clear a board',
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

const _themeOptions = [
  (mode: ThemeMode.system, label: 'System'),
  (mode: ThemeMode.light, label: 'Light'),
  (mode: ThemeMode.dark, label: 'Dark'),
];

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final foreground = selected ? colors.onAccent : colors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Ink(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            color: selected
                ? colors.accent
                : colors.accent.withValues(alpha: 0.06),
            border: Border.all(
              color: selected
                  ? colors.accent
                  : colors.accent.withValues(alpha: 0.28),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingDivider extends StatelessWidget {
  const _SettingDivider();

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.border.withValues(alpha: 0.7)),
        child: const SizedBox(height: 1, width: double.infinity),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.switchKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final Key switchKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = GameColors.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.accent, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: text.bodyMedium),
              ],
            ),
          ),
          Switch(key: switchKey, value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
