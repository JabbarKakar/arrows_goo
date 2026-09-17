import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/app_settings.dart';
import 'ui/daily/daily_screen.dart';
import 'ui/home/home_screen.dart';
import 'ui/play/play_screen.dart';
import 'ui/settings/settings_screen.dart';

class ArrowsGooApp extends ConsumerWidget {
  const ArrowsGooApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appSettingsProvider).themeMode;

    return MaterialApp(
      title: 'Arrows Goo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.play: (_) => const PlayScreen(),
        AppRoutes.daily: (_) => const DailyScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
