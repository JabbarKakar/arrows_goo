import 'package:arrows_goo/app.dart';
import 'package:arrows_goo/core/clock.dart';
import 'package:arrows_goo/core/feel/feel_service.dart';
import 'package:arrows_goo/core/storage/app_settings.dart';
import 'package:arrows_goo/core/storage/campaign_progress.dart';
import 'package:arrows_goo/core/storage/daily_progress.dart';
import 'package:arrows_goo/core/storage/tutorial_seen.dart';
import 'package:arrows_goo/game/levels/level_catalog.dart';
import 'package:arrows_goo/game/session/play_session.dart';
import 'package:arrows_goo/game/session/play_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_feel_service.dart';

SharedPreferences? _prefs;
LevelCatalog? _catalog;

Future<LevelCatalog> loadTutorialCatalog() async {
  _catalog ??= LevelCatalog.parse(
    await rootBundle.loadString('assets/levels/tutorial.json'),
  );
  return _catalog!;
}

Future<SharedPreferences> _prefsWith(Map<String, Object> values) async {
  if (_prefs == null) {
    SharedPreferences.setMockInitialValues(Map<String, Object>.from(values));
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  await _prefs!.clear();
  for (final entry in values.entries) {
    final value = entry.value;
    if (value is int) {
      await _prefs!.setInt(entry.key, value);
    } else if (value is String) {
      await _prefs!.setString(entry.key, value);
    } else if (value is bool) {
      await _prefs!.setBool(entry.key, value);
    } else {
      throw ArgumentError('Unsupported pref ${value.runtimeType}');
    }
  }
  return _prefs!;
}

Future<ProviderScope> createTestApp({
  Map<String, Object> prefs = const {},
  DateTime? now,
}) async {
  final sp = await _prefsWith(prefs);
  final catalog = await loadTutorialCatalog();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      levelCatalogProvider.overrideWithValue(catalog),
      feelServiceProvider.overrideWithValue(FakeFeelService()),
      if (now != null) clockProvider.overrideWithValue(() => now),
    ],
    child: const ArrowsGooApp(),
  );
}

Future<ProviderContainer> createTestContainer({
  Map<String, Object> prefs = const {},
  int startLevel = 1,
  PlayConfig? config,
  DateTime? now,
}) async {
  final sp = await _prefsWith(prefs);
  final catalog = await loadTutorialCatalog();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sp),
      levelCatalogProvider.overrideWithValue(catalog),
      feelServiceProvider.overrideWithValue(FakeFeelService()),
      playConfigProvider.overrideWith(
        (_) => config ?? PlayConfig.campaign(startLevel),
      ),
      if (now != null) clockProvider.overrideWithValue(() => now),
    ],
  );
  container.listen(playSessionProvider, (previous, next) {});
  container.listen(campaignProgressProvider, (previous, next) {});
  container.listen(dailyProgressProvider, (previous, next) {});
  container.listen(appSettingsProvider, (previous, next) {});
  container.listen(tutorialSeenProvider, (previous, next) {});
  return container;
}

FakeFeelService feelOf(ProviderContainer container) {
  return container.read(feelServiceProvider) as FakeFeelService;
}
