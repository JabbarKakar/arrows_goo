import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'campaign_progress.dart';

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.celebrationsEnabled = true,
  });

  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool celebrationsEnabled;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? celebrationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      celebrationsEnabled: celebrationsEnabled ?? this.celebrationsEnabled,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const themeKey = 'settings.themeMode';
  static const soundKey = 'settings.sound';
  static const hapticsKey = 'settings.haptics';
  static const celebrationsKey = 'settings.celebrations';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      themeMode: _themeFrom(prefs.getString(themeKey)),
      soundEnabled: prefs.getBool(soundKey) ?? true,
      hapticsEnabled: prefs.getBool(hapticsKey) ?? true,
      celebrationsEnabled: prefs.getBool(celebrationsKey) ?? true,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(sharedPreferencesProvider).setString(themeKey, _themeToken(mode));
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await ref.read(sharedPreferencesProvider).setBool(soundKey, enabled);
    state = state.copyWith(soundEnabled: enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    await ref.read(sharedPreferencesProvider).setBool(hapticsKey, enabled);
    state = state.copyWith(hapticsEnabled: enabled);
  }

  Future<void> setCelebrationsEnabled(bool enabled) async {
    await ref.read(sharedPreferencesProvider).setBool(celebrationsKey, enabled);
    state = state.copyWith(celebrationsEnabled: enabled);
  }

  static ThemeMode _themeFrom(String? token) {
    return switch (token) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _themeToken(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
