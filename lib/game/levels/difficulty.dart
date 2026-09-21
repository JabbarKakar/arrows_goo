enum DifficultyTier {
  easy,
  medium,
  hard,
  superHard,
  nightmarish;

  static DifficultyTier forLevel(int level) {
    if (level <= 20) return easy;
    if (level <= 40) return medium;
    if (level <= 70) return hard;
    if (level <= 100) return superHard;
    return nightmarish;
  }

  String get label => switch (this) {
        easy => 'Easy',
        medium => 'Medium',
        hard => 'Hard',
        superHard => 'Super Hard',
        nightmarish => 'Nightmarish',
      };
}
