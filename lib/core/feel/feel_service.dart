import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/sfx_library.dart';
import '../storage/app_settings.dart';

abstract class FeelService {
  Future<void> validMove();
  Future<void> blockedTap();
  Future<void> cleared();
}

class AppFeelService implements FeelService {
  AppFeelService(this._ref);

  final Ref _ref;
  final _whoosh = AudioPlayer();
  final _tap = AudioPlayer();
  final _clear = AudioPlayer();

  AppSettings get _settings => _ref.read(appSettingsProvider);

  @override
  Future<void> validMove() async {
    await Future.wait([
      _haptic(HapticFeedback.lightImpact),
      _play(_whoosh, SfxLibrary.whoosh),
    ]);
  }

  @override
  Future<void> blockedTap() async {
    await Future.wait([
      _haptic(HapticFeedback.mediumImpact),
      _play(_tap, SfxLibrary.tap),
    ]);
  }

  @override
  Future<void> cleared() async {
    await Future.wait([
      _haptic(HapticFeedback.lightImpact),
      _play(_clear, SfxLibrary.clear),
    ]);
  }

  Future<void> _haptic(Future<void> Function() run) async {
    if (!_settings.hapticsEnabled) return;
    await run();
  }

  Future<void> _play(AudioPlayer player, Uint8List bytes) async {
    if (!_settings.soundEnabled) return;
    await player.stop();
    await player.play(BytesSource(bytes, mimeType: 'audio/wav'));
  }

  Future<void> dispose() async {
    await Future.wait([
      _whoosh.dispose(),
      _tap.dispose(),
      _clear.dispose(),
    ]);
  }
}

final feelServiceProvider = Provider<FeelService>((ref) {
  final service = AppFeelService(ref);
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
});
