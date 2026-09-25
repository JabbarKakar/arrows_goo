enum DifficultyTier {
  easy,
  medium,
  hard,
  superHard,
  nightmarish;

  /// Target number of arrows (pieces) for generated boards in this tier.
  int get minArrows => switch (this) {
        easy => 35,
        medium => 70,
        hard => 130,
        superHard => 200,
        nightmarish => 300,
      };

  int get maxArrows => switch (this) {
        easy => 50,
        medium => 100,
        hard => 160,
        superHard => 250,
        nightmarish => 350,
      };

  /// Hand-authored tutorial boards stay Easy. Generated campaign levels
  /// shuffle across all five tiers so you do not climb in locked bands.
  static DifficultyTier forLevel(int level) {
    if (level <= 8) return easy;
    DifficultyTier? previous;
    var tier = easy;
    for (var i = 9; i <= level; i++) {
      tier = _roll(i, previous);
      previous = tier;
    }
    return tier;
  }

  static DifficultyTier _roll(int level, DifficultyTier? previous) {
    const pool = [
      easy,
      medium,
      hard,
      superHard,
      nightmarish,
      easy,
      hard,
      nightmarish,
      medium,
      superHard,
    ];
    var state = (level * 1103515245 + 92821) & 0x7fffffff;
    int nextInt(int max) {
      state = (state * 1103515245 + 12345) & 0x7fffffff;
      return state % max;
    }

    final items = [...pool];
    for (var pass = 0; pass < 2; pass++) {
      for (var i = items.length - 1; i > 0; i--) {
        final j = nextInt(i + 1);
        final tmp = items[i];
        items[i] = items[j];
        items[j] = tmp;
      }
    }
    return items.firstWhere(
      (tier) => tier != previous,
      orElse: () => items.first,
    );
  }

  /// Countdown for a campaign level. Shorter clocks are part of the harder tiers.
  int get timeLimitSeconds => switch (this) {
        easy => 4 * 60,
        medium => 3 * 60,
        hard => 2 * 60 + 30,
        superHard => 2 * 60,
        nightmarish => 90,
      };

  String get label => switch (this) {
        easy => 'Easy',
        medium => 'Medium',
        hard => 'Hard',
        superHard => 'Super Hard',
        nightmarish => 'Nightmarish',
      };

  static String levelTitle(int level) =>
      'Level $level · ${forLevel(level).label}';
}
