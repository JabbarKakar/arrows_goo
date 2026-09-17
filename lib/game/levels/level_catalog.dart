import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../engine/level_generator.dart';
import '../models/board.dart';
import 'daily_puzzle.dart';

class LevelCatalog {
  const LevelCatalog({required this.tutorial});

  final List<Board> tutorial;

  int get tutorialCount => tutorial.length;

  static LevelCatalog parse(String jsonString) {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final rawLevels = data['levels'] as List<dynamic>;
    final tutorial = rawLevels.map((raw) {
      final map = raw as Map<String, dynamic>;
      final grid = (map['grid'] as List<dynamic>).cast<String>();
      return Board.parse(grid);
    }).toList(growable: false);
    return LevelCatalog(tutorial: tutorial);
  }

  Board boardFor(int level) {
    if (level < 1) {
      throw ArgumentError.value(level, 'level');
    }
    if (level <= tutorial.length) {
      return tutorial[level - 1];
    }
    return LevelGenerator(seed: level).generate(CampaignSpec.forLevel(level));
  }

  Board boardForDaily(String dailyId) {
    return LevelGenerator(seed: DailyPuzzle.seedFor(dailyId))
        .generate(DailyPuzzle.specFor(dailyId));
  }
}

final levelCatalogProvider = Provider<LevelCatalog>((ref) {
  throw StateError('levelCatalogProvider must be overridden');
});
