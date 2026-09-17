import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/storage/campaign_progress.dart';
import 'game/levels/level_catalog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();
  final tutorialJson = await rootBundle.loadString('assets/levels/tutorial.json');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        levelCatalogProvider.overrideWithValue(LevelCatalog.parse(tutorialJson)),
      ],
      child: const ArrowsGooApp(),
    ),
  );
}
