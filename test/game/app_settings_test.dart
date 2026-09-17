import 'package:arrows_goo/core/storage/app_settings.dart';
import 'package:arrows_goo/core/storage/daily_progress.dart';
import 'package:arrows_goo/core/storage/tutorial_seen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults are system theme with sound and haptics on', () async {
    final container = await createTestContainer();
    addTearDown(container.dispose);
    final settings = container.read(appSettingsProvider);
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.soundEnabled, isTrue);
    expect(settings.hapticsEnabled, isTrue);
    expect(settings.celebrationsEnabled, isTrue);
  });

  test('theme and toggles persist in memory', () async {
    final container = await createTestContainer();
    addTearDown(container.dispose);
    final notifier = container.read(appSettingsProvider.notifier);

    await notifier.setThemeMode(ThemeMode.dark);
    await notifier.setSoundEnabled(false);
    await notifier.setHapticsEnabled(false);
    await notifier.setCelebrationsEnabled(false);

    final settings = container.read(appSettingsProvider);
    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.soundEnabled, isFalse);
    expect(settings.hapticsEnabled, isFalse);
    expect(settings.celebrationsEnabled, isFalse);
  });

  test('daily completion is stored by id', () async {
    final container = await createTestContainer();
    addTearDown(container.dispose);
    await container.read(dailyProgressProvider.notifier).markComplete('20260917');
    expect(container.read(dailyProgressProvider), '20260917');
  });

  test('tutorial seen starts false and can be marked', () async {
    final container = await createTestContainer();
    addTearDown(container.dispose);
    expect(container.read(tutorialSeenProvider), isFalse);
    await container.read(tutorialSeenProvider.notifier).markSeen();
    expect(container.read(tutorialSeenProvider), isTrue);
  });
}
