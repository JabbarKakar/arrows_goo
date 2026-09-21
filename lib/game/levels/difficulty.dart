enum DifficultyTier {
  easy,
  medium,
  hard,
  superHard,
  nightmarish;

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

  String get label => switch (this) {
        easy => 'Easy',
        medium => 'Medium',
        hard => 'Hard',
        superHard => 'Super Hard',
        nightmarish => 'Nightmarish',
      };
}
