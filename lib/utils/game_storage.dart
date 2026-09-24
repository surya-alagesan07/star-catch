import 'package:shared_preferences/shared_preferences.dart';

class GameStorage {
  // 📊 Progress
  static const totalStarsKey = 'total_stars';
  static const totalCoinsKey = 'total_coins';
  static const bestComboKey = 'best_combo';
  static const levelKey = 'player_level';
  static const bestKey = 'high_score';
  static const scoresKey = 'leaderboard';
  static const achievementsKey = 'achievements';
  static const themeKey = 'theme';
  static const skinKey = 'skin';

  // 👤 Profile
  static const playerNameKey = 'player_name';
  static const gamesPlayedKey = 'games_played';

  static Future<Map<String, dynamic>> load() async {
    final p = await SharedPreferences.getInstance();

    return {
      'best': p.getInt(bestKey) ?? 0,
      'theme': p.getString(themeKey),
      'skin': p.getString(skinKey),
      'achievements':
      p.getStringList(achievementsKey) ?? <String>[],

      // 👤 Profile
      'playerName':
      p.getString(playerNameKey) ?? 'Star Catcher',
      'gamesPlayed':
      p.getInt(gamesPlayedKey) ?? 0,
      'avatar':
      p.getInt(avatarKey) ?? 0,

      // 📊 Progress
      'totalStars':
      p.getInt(totalStarsKey) ?? 0,
      'totalCoins':
      p.getInt(totalCoinsKey) ?? 0,
      'bestCombo':
      p.getInt(bestComboKey) ?? 0,
      'level':
      p.getInt(levelKey) ?? 1,
    };
  }

  // ⭐ Total stars
  static Future<int> getTotalStars() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(totalStarsKey) ?? 0;
  }

  static Future<void> addStars(int amount) async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt(totalStarsKey) ?? 0;
    await p.setInt(totalStarsKey, current + amount);
  }

// 🪙 Total coins
  static Future<int> getTotalCoins() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(totalCoinsKey) ?? 0;
  }

  static Future<void> addCoins(int amount) async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt(totalCoinsKey) ?? 0;
    await p.setInt(totalCoinsKey, current + amount);
  }

// 🔥 Best combo
  static Future<int> getBestCombo() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(bestComboKey) ?? 0;
  }

  static Future<void> saveBestCombo(int combo) async {
    final p = await SharedPreferences.getInstance();
    final current = p.getInt(bestComboKey) ?? 0;

    if (combo > current) {
      await p.setInt(bestComboKey, combo);
    }
  }

// 📈 Player level
  static Future<int> getLevel() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(levelKey) ?? 1;
  }

  static Future<void> saveLevel(int level) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(levelKey, level);
  }

  static Future<void> saveSettings({
    required String theme,
    required String skin,
    required Set<String> achievements,
  }) async {
    final p = await SharedPreferences.getInstance();

    await p.setString(themeKey, theme);
    await p.setString(skinKey, skin);
    await p.setStringList(
      achievementsKey,
      achievements.toList(),
    );
  }

  static Future<void> saveBest(int score) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(bestKey, score);
  }

  static const avatarKey = 'player_avatar';

  static Future<void> saveAvatar(int avatar) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(avatarKey, avatar);
  }

  static Future<int> getAvatar() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(avatarKey) ?? 0;
  }

  static Future<void> addScore(int score) async {
    final p = await SharedPreferences.getInstance();
    final scores = p.getStringList(scoresKey) ?? [];

    scores.add(score.toString());

    scores.sort(
          (a, b) => int.parse(b).compareTo(int.parse(a)),
    );

    if (scores.length > 10) {
      scores.removeRange(10, scores.length);
    }

    await p.setStringList(scoresKey, scores);
  }

  static Future<List<int>> leaderboard() async {
    final p = await SharedPreferences.getInstance();

    return (p.getStringList(scoresKey) ?? [])
        .map(int.parse)
        .toList();
  }

  // 👤 Save player name
  static Future<void> savePlayerName(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(playerNameKey, name);
  }

  // 🎮 Games played
  static Future<int> getGamesPlayed() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(gamesPlayedKey) ?? 0;
  }

  static Future<void> incrementGamesPlayed() async {
    final p = await SharedPreferences.getInstance();
    final games = p.getInt(gamesPlayedKey) ?? 0;
    await p.setInt(gamesPlayedKey, games + 1);
  }
}