enum Difficulty {
  easy,
  normal,
  hard,
  endless,
}

class DifficultyConfig {
  final String name;
  final int startTime;
  final int lives;
  final int minDelay;
  final int speedStep;
  final bool endless;

  const DifficultyConfig(
      this.name,
      this.startTime,
      this.lives,
      this.minDelay,
      this.speedStep,
      this.endless,
      );

  static DifficultyConfig get(Difficulty d) {
    switch (d) {
      case Difficulty.easy:
        return const DifficultyConfig(
          'EASY', 45, 4, 1100, 150, false,
        );

      case Difficulty.normal:
        return const DifficultyConfig(
          'NORMAL', 30, 3, 700, 250, false,
        );

      case Difficulty.hard:
        return const DifficultyConfig(
          'HARD', 20, 2, 450, 350, false,
        );

      case Difficulty.endless:
        return const DifficultyConfig(
          'ENDLESS', 0, 3, 650, 250, true,
        );
    }
  }
}