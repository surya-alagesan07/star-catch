import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../audio/audio_settings.dart';
import '../audio/game_audio.dart';
import '../effects/game_effects.dart';
import '../features/achievements.dart';
import '../features/game_modes.dart';
import '../features/leaderboard.dart';
import '../features/missions.dart';
import '../features/daily_rewards.dart';
import '../features/player_profile.dart';
import '../features/skins.dart';
import '../features/themes.dart';
import '../utils/game_storage.dart';
import '../features/coin_wallet.dart';
import 'difficulty.dart';
import 'game_controller.dart';
import 'game_item.dart';

class StarGame extends StatefulWidget {
  const StarGame({super.key});

  @override
  State<StarGame> createState() => _StarGameState();
}

class _StarGameState extends State<StarGame> {

  GameMode gameMode = GameMode.normal;

  // 🎮 GAME MODE SETTINGS
  int challengeTarget = 20;
  int comboTarget = 15;

  // 🎮 Difficulty
  Difficulty difficulty = Difficulty.normal;

  DifficultyConfig get config => DifficultyConfig.get(difficulty);


  bool get modeUsesTimer {
    switch (gameMode) {
      case GameMode.normal:
        return !config.endless;

      case GameMode.timeAttack:
        return true;

      case GameMode.survival:
        return false;

      case GameMode.challenge:
        return true;

      case GameMode.combo:
        return true;
    }
  }

  int get startingTime {
    switch (gameMode) {
      case GameMode.normal:
        return config.endless ? 0 : 60;

      case GameMode.timeAttack:
        return 60;

      case GameMode.survival:
        return 0;

      case GameMode.challenge:
        return 90;

      case GameMode.combo:
        return 60;
    }
  }

  int get startingLives {
    switch (gameMode) {
      case GameMode.normal:
        return config.lives;

      case GameMode.timeAttack:
        return 3;

      case GameMode.survival:
        return 3;

      case GameMode.challenge:
        return 3;

      case GameMode.combo:
        return 3;
    }
  }



  static const native =
  MethodChannel('com.example.flutter_java_game/game');

  final game = GameController();
  final audio = GameAudio();

  int score = 0, best = 0, time = 30, lives = 3;

  bool playing = false;
  bool paused = false;
  bool hasShield = false;

  int coins = 0;
  int freezeSeconds = 0;
  int multiplierSeconds = 0;
  int starsCaught = 0;

  String playerName = 'Star Catcher';

  int itemsCaught = 0;
  int powerUps = 0;
  int perfectCatch = 0;

  int totalStars = 0;
  int totalCoins = 0;
  int progressBestCombo = 0;
  int gamesPlayed = 0;

  // 🎯 COMBO
  int combo = 0;
  int bestCombo = 0;

  Item item = Item.star;

  ThemeType theme = ThemeType.space;
  SkinType skin = SkinType.classic;

  final achievements = <String>{};

  // 🎆 Effects
  bool pop = false;
  bool shake = false;
  bool particles = false;
  bool levelUp = false;

  double particleX = .5;
  double particleY = .5;


  int get level => score ~/ 5 + 1;

  Color get background => Themes.background(theme);

  int get comboBonus {
    if (combo >= 20) return 5;
    if (combo >= 10) return 2;
    if (combo >= 5) return 1;
    return 0;
  }

  String get comboText => combo >= 2 ? '🔥 $combo×' : '—';

  Map<String, MissionProgress> missionData = {};

  int avoidedBombs = 0;
  int survivedSeconds = 0;
  @override
  void initState() {
    super.initState();
    loadData();
    audio.init();
  }

  Future<void> loadData() async {
    final d = await GameStorage.load();
    final missionRaw = await Missions.load();
    final loadedMissions = Missions.decode(missionRaw);
    final walletCoins = await CoinWallet.getCoins();

    if (!mounted) return;

    setState(() {
      best = d['best'];
      coins = walletCoins;

      theme = ThemeType.values.firstWhere(
            (e) => e.name == d['theme'],
        orElse: () => ThemeType.space,
      );

      skin = SkinType.values.firstWhere(
            (e) => e.name == d['skin'],
        orElse: () => SkinType.classic,
      );

      achievements.addAll(d['achievements']);
      missionData = loadedMissions;

      // 👤 Player Profile
      playerName = d['playerName'] ?? 'Star Catcher';
      gamesPlayed = d['gamesPlayed'] ?? 0;

      // 📊 Progress
      totalStars = d['totalStars'] ?? 0;
      totalCoins = d['totalCoins'] ?? 0;
      progressBestCombo = d['bestCombo'] ?? 0;
    });
  }

  Future<void> saveData() {
    return GameStorage.saveSettings(
      theme: theme.name,
      skin: skin.name,
      achievements: achievements,
    );
  }

  Future<void> feedback(
      String method,
      Future<void> fallback,
      ) async {
    try {
      await native.invokeMethod(method);
    } catch (_) {
      await fallback;
    }
  }

  void moveItem() => item = game.nextItem();

  int get delay {
    final base = max(
      config.minDelay,
      3000 - (level - 1) * config.speedStep,
    );

    return freezeSeconds > 0 ? base * 2 : base;
  }

  // 🎮 Difficulty selection
  void chooseDifficulty() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🎮 DIFFICULTY'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((d) {
            final c = DifficultyConfig.get(d);

            return ListTile(
              leading: Icon(
                difficulty == d
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(c.name),
              subtitle: Text(
                c.endless
                    ? 'No time limit'
                    : '${c.startTime}s • ${c.lives} lives',
              ),
              onTap: () {
                setState(() => difficulty = d);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> startGame() async {
    game.cancel();

    await GameStorage.incrementGamesPlayed();

    final newTime = startingTime;
    final newLives = startingLives;

    setState(() {
      score = 0;
      time = newTime;
      lives = newLives;

      playing = true;
      paused = false;

      combo = 0;
      bestCombo = 0;

      gamesPlayed++;

      hasShield = false;
      freezeSeconds = 0;
      multiplierSeconds = 0;

      starsCaught = 0;
      itemsCaught = 0;
      powerUps = 0;
      perfectCatch = 0;

      avoidedBombs = 0;
      survivedSeconds = 0;

      item = Item.star;
    });

    await audio.startMusic();

    moveItem();
    scheduleItem();

    // 🎮 Mode-specific starting message
    switch (gameMode) {
      case GameMode.normal:
        break;

      case GameMode.timeAttack:
        _showModeMessage(
          '⏱️ TIME ATTACK',
          '60 seconds! Catch as many stars as possible!',
          Colors.cyanAccent,
        );
        break;

      case GameMode.survival:
        _showModeMessage(
          '❤️ SURVIVAL',
          'No timer! Survive until you lose all lives.',
          Colors.redAccent,
        );
        break;

      case GameMode.challenge:
        _showModeMessage(
          '🎯 CHALLENGE',
          'Reach $challengeTarget stars!',
          Colors.orangeAccent,
        );
        break;

      case GameMode.combo:
        _showModeMessage(
          '🔥 COMBO',
          'Reach a $comboTarget× combo!',
          Colors.deepPurpleAccent,
        );
        break;
    }

    game.gameTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (!playing || paused) return;

        // ❤️ SURVIVAL has no countdown.
        if (gameMode == GameMode.survival) {
          setState(() {
            survivedSeconds++;

            if (freezeSeconds > 0) {
              freezeSeconds--;
            }

            if (multiplierSeconds > 0) {
              multiplierSeconds--;
            }
          });

          return;
        }

        // ⏱️ Other timed modes.
        if (modeUsesTimer && time <= 1) {
          setState(() {
            time = 0;
          });

          finish();
          return;
        }

        setState(() {
          if (modeUsesTimer) {
            time--;
          }

          survivedSeconds++;

          if (freezeSeconds > 0) {
            freezeSeconds--;
          }

          if (multiplierSeconds > 0) {
            multiplierSeconds--;
          }
        });
      },
    );
  }

  void _showModeMessage(
      String title,
      String message,
      Color color,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0B1330),
        content: Row(
          children: [
            Icon(
              gameMode.icon,
              color: color,
              size: 30,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scheduleItem() {
    game.itemTimer?.cancel();

    if (!playing || paused) return;

    game.itemTimer = Timer(
      Duration(milliseconds: delay),
          () {
        if (!playing || paused) return;

        // 💣 Missing a bomb does not lose life.
        if (item == Item.bomb) {
          avoidedBombs++;

          setState(moveItem);

          updateMissions();

          scheduleItem();
          return;
        }

        // 🛡️ Shield protects one missed item.
        if (hasShield) {
          setState(() {
            hasShield = false;
            moveItem();
          });

          scheduleItem();
          return;
        }

        // ❌ Miss resets combo.
        perfectCatch = 0;
        combo = 0;

        if (lives <= 1) {
          setState(() => lives = 0);
          finish();
          return;
        }

        setState(() {
          lives--;
          combo = 0;
          moveItem();
        });

        missAnimation();

        audio.sound('miss.mp3');

        feedback(
          'missFeedback',
          HapticFeedback.heavyImpact(),
        );

        scheduleItem();
      },
    );
  }

  Future<void> pauseGame() async {
    if (!playing || paused) return;

    setState(() => paused = true);

    game.cancel();

    await audio.pauseMusic();
  }

  Future<void> resumeGame() async {
    if (!playing || !paused) return;

    setState(() => paused = false);

    await audio.resumeMusic();

    game.gameTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (!playing || paused) return;

        // ❤️ SURVIVAL
        if (gameMode == GameMode.survival) {
          setState(() {
            survivedSeconds++;

            if (freezeSeconds > 0) {
              freezeSeconds--;
            }

            if (multiplierSeconds > 0) {
              multiplierSeconds--;
            }
          });

          return;
        }

        // ⏱️ Timed modes
        if (modeUsesTimer && time <= 1) {
          setState(() {
            time = 0;
          });

          finish();
          return;
        }

        setState(() {
          if (modeUsesTimer) {
            time--;
          }

          survivedSeconds++;

          if (freezeSeconds > 0) {
            freezeSeconds--;
          }

          if (multiplierSeconds > 0) {
            multiplierSeconds--;
          }
        });
      },
    );

    scheduleItem();
  }

  Future<void> updateMissions() async {
    final updated = Missions.update(
      oldData: missionData,
      stars: starsCaught,
      combo: combo,
      powerUps: powerUps,
      avoidedBombs: avoidedBombs,
      score: score,
      survivedSeconds: survivedSeconds,
    );

    final newlyCompleted = <Mission>[];

    for (final mission in Missions.all) {
      final old =
          missionData[mission.id] ??
              const MissionProgress();

      final now =
          updated[mission.id] ??
              const MissionProgress();

      if (!old.completed && now.completed) {
        newlyCompleted.add(mission);
      }
    }

    missionData = updated;

    await Missions.save(missionData);

    if (!mounted) return;

    setState(() {});

    // Completion only unlocks the CLAIM button.
    // Coins are awarded once, when the player explicitly claims the mission.
    for (final mission in newlyCompleted) {
      showMissionCompleted(mission);
    }
  }

  void showMissionCompleted(Mission mission) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepPurple,
        content: Row(
          children: [
            const Text(
              '🎯',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MISSION COMPLETE!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    mission.title,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Reward: +${mission.reward}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> finish() async {
    if (!playing) return;

    game.cancel();
    await audio.stopMusic();

    if (score > best) {
      best = score;
      await GameStorage.saveBest(best);
    }

    await GameStorage.addScore(score);

    if (!mounted) return;

    setState(() {
      playing = false;
      paused = false;
    });

    audio.sound('game_over.mp3');

    feedback(
      'gameOverFeedback',
      HapticFeedback.heavyImpact(),
    );
  }

  // 🎆 Catch animation
  void catchAnimation(double px, double py) {
    setState(() {
      pop = true;
      particles = true;
      particleX = px;
      particleY = py;
    });

    Future.delayed(
      const Duration(milliseconds: 180),
          () {
        if (mounted) {
          setState(() => pop = false);
        }
      },
    );

    Future.delayed(
      const Duration(milliseconds: 450),
          () {
        if (mounted) {
          setState(() => particles = false);
        }
      },
    );
  }

  // ❌ Miss animation
  void missAnimation() {
    setState(() => shake = true);

    Future.delayed(
      const Duration(milliseconds: 250),
          () {
        if (mounted) {
          setState(() => shake = false);
        }
      },
    );
  }

  // 🆙 Level animation
  void levelAnimation() {
    setState(() => levelUp = true);

    Future.delayed(
      const Duration(milliseconds: 900),
          () {
        if (mounted) {
          setState(() => levelUp = false);
        }
      },
    );
  }

  Future<void> catchItem() async {
    if (!playing || paused) return;

    final caught = item;
    final oldLevel = level;

    final px = game.x;
    final py = game.y;

    final multiplier =
    multiplierSeconds > 0 ? 2 : 1;

    // 💥 Animation
    catchAnimation(px, py);

    // 💣 BOMB
    if (caught == Item.bomb) {
      pop = false;
      particles = false;

      missAnimation();

      perfectCatch = 0;
      combo = 0;

      if (lives <= 1) {
        setState(() => lives = 0);
        finish();
        return;
      }

      setState(() {
        lives--;
        combo = 0;
        moveItem();
      });

      scheduleItem();

      audio.sound('miss.mp3');

      feedback(
        'missFeedback',
        HapticFeedback.heavyImpact(),
      );

      return;
    }

    // 🎯 SUCCESSFUL CATCH
    combo++;

    if (combo > bestCombo) {
      bestCombo = combo;
    }

    if (combo > progressBestCombo) {
      progressBestCombo = combo;
      await GameStorage.saveBestCombo(combo);
    }
    // 🔥 COMBO MODE
    if (gameMode == GameMode.combo &&
        combo >= comboTarget) {
      Future.microtask(() {
        if (mounted) {
          _showModeMessage(
            '🔥 COMBO COMPLETE!',
            '$comboTarget× combo reached!',
            Colors.deepPurpleAccent,
          );

          finish();
        }
      });
    }
    void showComboAchievement(
        String title,
        String message,
        int reward,
        ) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.deepPurple,
          content: Row(
            children: [
              const Text(
                '🏆',
                style: TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '+$reward bonus point',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    setState(() {
      switch (caught) {
        case Item.star:
          score += 1 * multiplier + comboBonus;
          starsCaught++;
          totalStars++;
          // 🎯 CHALLENGE MODE
          if (gameMode == GameMode.challenge &&
              starsCaught >= challengeTarget) {
            Future.microtask(() {
              if (mounted) {
                _showModeMessage(
                  '🎯 CHALLENGE COMPLETE!',
                  '$challengeTarget stars caught!',
                  Colors.orangeAccent,
                );

                finish();
              }
            });
          }
          itemsCaught++;
          perfectCatch++;
          break;

        case Item.clock:
          time += 5;
          powerUps++;
          itemsCaught++;
          perfectCatch++;
          break;

        case Item.bolt:
          score += 2 * multiplier + comboBonus;
          powerUps++;
          itemsCaught++;
          perfectCatch++;
          break;

        case Item.shield:
          hasShield = true;
          powerUps++;
          itemsCaught++;
          perfectCatch++;
          break;

        case Item.freeze:
          freezeSeconds = 5;
          powerUps++;
          itemsCaught++;
          perfectCatch++;
          break;

        case Item.multiplier:
          multiplierSeconds = 5;
          powerUps++;
          itemsCaught++;
          perfectCatch++;
          break;

        case Item.bomb:
          break;
      }

      moveItem();
    });

    // 🆙 Level up
    if (level > oldLevel) {
      levelAnimation();
    }

    final wasComboBeginner =
    achievements.contains(Achievements.comboBeginner);

    final wasComboMaster =
    achievements.contains(Achievements.comboMaster);

    final wasComboLegend =
    achievements.contains(Achievements.comboLegend);

    Achievements.check(
      achievements,
      starsCaught,
      perfectCatch,
      score,
      powerUps,
      multiplierSeconds,
      combo: combo,
    );

    if (!wasComboBeginner &&
        achievements.contains(Achievements.comboBeginner)) {
      showComboAchievement(
        '🔥 COMBO BEGINNER!',
        '5× Combo reached!',
        1,
      );
    }

    if (!wasComboMaster &&
        achievements.contains(Achievements.comboMaster)) {
      showComboAchievement(
        '🔥 COMBO MASTER!',
        '10× Combo reached!',
        2,
      );
    }

    if (!wasComboLegend &&
        achievements.contains(Achievements.comboLegend)) {
      showComboAchievement(
        '🔥 COMBO LEGEND!',
        '20× Combo reached!',
        5,
      );
    }

    await saveData();
    await updateMissions();
    await GameStorage.addStars(1);

    scheduleItem();

    // 🔊 Sound
    audio.sound(
      caught == Item.star
          ? 'catch.mp3'
          : 'power_up.mp3',
    );

    feedback(
      'successFeedback',
      HapticFeedback.lightImpact(),
    );
  }

  String statusText() {
    final s = <String>[];

    if (combo >= 2) {
      s.add('🔥 Combo $combo×');
    }

    if (hasShield) {
      s.add('🛡️ Shield');
    }

    if (freezeSeconds > 0) {
      s.add('❄️ Freeze ${freezeSeconds}s');
    }

    if (multiplierSeconds > 0) {
      s.add('✖️ 2× ${multiplierSeconds}s');
    }

    if (s.isEmpty) {
      return '⭐ +1   🟢 +5 sec   🟣 +2   💣 -1 life';
    }

    return s.join('   ');
  }

  void openPlayerProfile() {
    PlayerProfile.show(
      context,
      background: background,
      playerName: playerName,
      bestScore: best,
      bestCombo: bestCombo,
      starsCaught: starsCaught,
      coins: coins,
      gamesPlayed: gamesPlayed,
      level: level,

      // 📊 Progress
      totalStars: totalStars,
      totalCoins: totalCoins,
      progressBestCombo: progressBestCombo,
      progressLevel: level,
    );
  }

  Widget _hudStat(String label, String value, IconData icon,
      {Color accent = Colors.white}) {
    return Container(
      constraints: const BoxConstraints(minWidth: 72),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .055),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .09)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 17),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white54, fontSize: 8,
                      fontWeight: FontWeight.w700, letterSpacing: .6)),
              Text(value,
                  style: TextStyle(color: accent, fontSize: 14,
                      fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundAction({required IconData icon, required String label,
    required VoidCallback onTap, Color accent = Colors.white}) {
    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: 58,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .055),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: .28)),
          ),
          child: Icon(icon, color: accent, size: 25),
        ),
      ),
    );
  }
  void openGameMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (menuContext) {
        return Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Icon(
                    Icons.menu_rounded,
                    color: Colors.cyanAccent,
                    size: 42,
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'GAME MENU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 22),

                  _menuItem(
                    icon: Icons.bar_chart_rounded,
                    title: 'Statistics',
                    subtitle: 'View your game statistics',
                    color: Colors.cyanAccent,
                    onTap: () {
                      Navigator.pop(menuContext);
                      _showStatistics();
                    },
                  ),

                  _menuItem(
                    icon: Icons.sports_esports_rounded,
                    title: 'Game Modes',
                    subtitle: 'Normal, Time Attack, Survival & more',
                    color: Colors.cyanAccent,
                    onTap: () async {
                      Navigator.pop(menuContext);

                      final selected = await GameModes.show(
                        context,
                        current: gameMode,
                      );

                      if (selected != null && mounted) {
                        setState(() {
                          gameMode = selected;
                        });
                      }
                    },
                  ),

                  _menuItem(
                    icon: Icons.track_changes_rounded,
                    title: 'Missions',
                    subtitle: 'Complete missions and earn rewards',
                    color: Colors.orangeAccent,
                    onTap: () {
                      Navigator.pop(menuContext);

                      Missions.show(
                        context,
                        background,
                        missionData,
                            () {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),

                  _menuItem(
                    icon: Icons.card_giftcard_rounded,
                    title: 'Daily Rewards',
                    subtitle: 'Collect your daily reward',
                    color: Colors.amberAccent,
                    onTap: () {
                      Navigator.pop(menuContext);

                      DailyRewards.show(
                        context,
                        background: background,
                        onChanged: () async {
                          final updatedCoins =
                          await CoinWallet.getCoins();

                          if (mounted) {
                            setState(() {
                              coins = updatedCoins;
                            });
                          }
                        },
                      );
                    },
                  ),

                  _menuItem(
                    icon: Icons.emoji_events_rounded,
                    title: 'Achievements',
                    subtitle: 'View your achievements',
                    color: Colors.amber,
                    onTap: () {
                      Navigator.pop(menuContext);

                      Achievements.show(
                        context,
                        background,
                        achievements,
                      );
                    },
                  ),

                  _menuItem(
                    icon: Icons.leaderboard_rounded,
                    title: 'Leaderboard',
                    subtitle: 'View your scores',
                    color: Colors.greenAccent,
                    onTap: () {
                      Navigator.pop(menuContext);

                      Leaderboard.show(
                        context,
                        background,
                      );
                    },
                  ),

                  _menuItem(
                    icon: Icons.palette_rounded,
                    title: 'Themes & Skins',
                    subtitle: 'Customize your game',
                    color: Colors.pinkAccent,
                    onTap: () {
                      Navigator.pop(menuContext);
                      openCustomization();
                    },
                  ),

                  _menuItem(
                    icon: Icons.speed_rounded,
                    title: 'Difficulty',
                    subtitle: 'Change game difficulty',
                    color: Colors.cyanAccent,
                    onTap: () {
                      Navigator.pop(menuContext);
                      chooseDifficulty();
                    },
                  ),

                  _menuItem(
                    icon: Icons.volume_up_rounded,
                    title: 'Audio',
                    subtitle: 'Sound and music settings',
                    color: Colors.purpleAccent,
                    onTap: () {
                      Navigator.pop(menuContext);

                      AudioSettings.show(
                        context,
                        background: background,
                        audio: audio,
                        onChanged: () {
                          if (mounted) {
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  void _showStatistics() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(30),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: .10),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.cyanAccent,
                    size: 42,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'STATISTICS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _statRow('Current Score', '$score', Icons.star_rounded, Colors.amber),
                  _statRow('Best Score', '$best', Icons.emoji_events_rounded, Colors.orangeAccent),
                  _statRow('Level', '$level', Icons.trending_up_rounded, Colors.cyanAccent),
                  _statRow('Stars Caught', '$starsCaught', Icons.auto_awesome_rounded, Colors.amberAccent),
                  _statRow('Power-Ups', '$powerUps', Icons.bolt_rounded, Colors.purpleAccent),
                  _statRow('Best Combo', '$bestCombo×', Icons.local_fire_department_rounded, Colors.deepPurpleAccent),
                  _statRow('Bombs Avoided', '$avoidedBombs', Icons.warning_amber_rounded, Colors.orangeAccent),
                  _statRow('Survival Time', '${survivedSeconds}s', Icons.timer_rounded, Colors.greenAccent),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text(
                        'CLOSE',
                        style: TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _statRow(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .045),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: color.withValues(alpha: .18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: color.withValues(alpha: .65),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeBadge() {
    final info = gameMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          info.iconColor.withValues(alpha: .22),
          Colors.white.withValues(alpha: .04),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: info.iconColor.withValues(alpha: .45)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(info.icon, color: info.iconColor, size: 18),
        const SizedBox(width: 7),
        Text(info.title, style: TextStyle(color: info.iconColor,
            fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: .7)),
      ]),
    );
  }

  void openCustomization() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheet) {
          return Container(
            height: MediaQuery.of(context).size.height * .82,
            decoration: BoxDecoration(
              color: background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(color: Colors.white.withValues(alpha: .1)),
            ),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
                children: [
                  Center(child: Container(width: 42, height: 4,
                      decoration: BoxDecoration(color: Colors.white24,
                          borderRadius: BorderRadius.circular(4)))),
                  const SizedBox(height: 18),
                  const Text('🎨 CUSTOMIZE', textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 27,
                          fontWeight: FontWeight.w900, letterSpacing: .5)),
                  const SizedBox(height: 5),
                  const Text('Choose your arena and star style', textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 24),
                  const Text('THEMES', style: TextStyle(color: Colors.amber,
                      fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 650 ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10, mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                    children: ThemeType.values.map((t) {
                      final unlocked = Themes.unlocked(t, best);
                      final selected = theme == t;
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: unlocked ? () { setState(() => theme=t); setSheet(() {}); saveData(); } : null,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Themes.color(t).withValues(alpha: .11),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: selected ? Themes.color(t) : Colors.white12, width: selected ? 2 : 1),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.blur_on_rounded, color: Themes.color(t), size: 31),
                            const SizedBox(height: 6),
                            Text(Themes.name(t), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(selected ? 'SELECTED ✓' : unlocked ? 'UNLOCKED' : '🔒 ${Themes.text(t).split('—').last.trim()}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: selected ? Colors.greenAccent : Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('STAR SKINS', style: TextStyle(color: Colors.amber,
                      fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                  const SizedBox(height: 10),
                  GridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 650 ? 5 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10, mainAxisSpacing: 10,
                    childAspectRatio: 1.05,
                    children: SkinType.values.map((s) {
                      final unlocked = Skins.unlocked(s, best);
                      final selected = skin == s;
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: unlocked ? () { setState(() => skin=s); setSheet(() {}); saveData(); } : null,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Skins.color(s).withValues(alpha: .10),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: selected ? Skins.color(s) : Colors.white12, width: selected ? 2 : 1),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.star_rounded, color: Skins.color(s), size: 40),
                            Text(Skins.text(s).split('—').first.trim(), textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(selected ? 'SELECTED ✓' : unlocked ? 'UNLOCKED' : '🔒',
                                style: TextStyle(color: selected ? Colors.greenAccent : Colors.white54, fontSize: 9, fontWeight: FontWeight.bold)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [background, Color.lerp(background, Colors.black, .34)!],
            ),
          ),
          child: Column(
            children: [
              // ───────── ADVANCED HUD ─────────
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .16),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 👤 PROFILE — TOP LEFT
                    _roundAction(
                      icon: Icons.person_rounded,
                      label: 'Profile',
                      accent: Colors.cyanAccent,
                      onTap: openPlayerProfile,
                    ),

                    const SizedBox(width: 8),

                    // GAME STATS
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _hudStat(
                              'SCORE',
                              '$score',
                              Icons.star_rounded,
                              accent: Colors.amber,
                            ),
                            const SizedBox(width: 7),

                            _hudStat(
                              'BEST',
                              '$best',
                              Icons.emoji_events_rounded,
                              accent: Colors.orangeAccent,
                            ),
                            const SizedBox(width: 7),

                            _hudStat(
                              'LEVEL',
                              '$level',
                              Icons.trending_up_rounded,
                              accent: Colors.cyanAccent,
                            ),
                            const SizedBox(width: 7),

                            _hudStat(
                              'LIVES',
                              '$lives',
                              Icons.favorite_rounded,
                              accent: Colors.redAccent,
                            ),
                            const SizedBox(width: 7),

                            _hudStat(
                              'COINS',
                              '$coins',
                              Icons.monetization_on_rounded,
                              accent: Colors.amber,
                            ),
                            const SizedBox(width: 7),

                            _hudStat(
                              'COMBO',
                              comboText,
                              Icons.local_fire_department_rounded,
                              accent: Colors.deepPurpleAccent,
                            ),
                            const SizedBox(width: 10),

                            _modeBadge(),
                            const SizedBox(width: 10),

                            // ⏸ PAUSE / ▶ RESUME
                            _roundAction(
                              icon: paused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              label: paused ? 'Resume' : 'Pause',
                              accent: Colors.white,
                              onTap: paused ? resumeGame : pauseGame,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // ☰ MENU — TOP RIGHT
                    _roundAction(
                      icon: Icons.menu_rounded,
                      label: 'Menu',
                      accent: Colors.cyanAccent,
                      onTap: openGameMenu,
                    ),
                  ],
                ),
              ),

              // ───────── PLAY AREA ─────────
              Expanded(
                child: LayoutBuilder(
                  builder: (_, c) {
                    return Stack(
                      children: [
                            Positioned.fill(
                              child: CustomPaint(painter: _ArenaPainter()),
                            ),
                            Positioned(
                              top: 18, left: 18, right: 18,
                              child: Row(children: [
                                if (playing && !config.endless)
                                  _statusPill(Icons.timer_rounded, '${time}s', Colors.cyanAccent),
                                const Spacer(),
                                if (freezeSeconds > 0) _statusPill(Icons.ac_unit_rounded, '${freezeSeconds}s', Colors.lightBlueAccent),
                                if (multiplierSeconds > 0) ...[
                                  const SizedBox(width: 7),
                                  _statusPill(Icons.close_rounded, '2× ${multiplierSeconds}s', Colors.purpleAccent),
                                ],
                                if (hasShield) ...[
                                  const SizedBox(width: 7),
                                  _statusPill(Icons.shield_rounded, 'SHIELD', Colors.greenAccent),
                                ],
                              ]),
                            ),
                            Center(child: IgnorePointer(child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.auto_awesome_rounded, color: Colors.white.withValues(alpha: .055), size: 92),
                              const SizedBox(height: 8),
                              Text('CATCH THE STAR', style: TextStyle(color: Colors.white.withValues(alpha: .08), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4)),
                            ]))),
                            if (playing && !paused)
                              Positioned(
                                left: c.maxWidth * game.x - 38,
                                top: c.maxHeight * game.y - 38,
                                child: Transform.translate(
                                  offset: shake ? const Offset(7, 0) : Offset.zero,
                                  child: GestureDetector(
                                    onTap: catchItem,
                                    child: AnimatedScale(
                                      scale: pop ? 1.35 : 1,
                                      duration: const Duration(milliseconds: 180),
                                      child: Container(
                                        padding: const EdgeInsets.all(9),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [BoxShadow(color: Skins.color(skin).withValues(alpha: .35), blurRadius: 28, spreadRadius: 4)],
                                        ),
                                        child: itemWidget(item, skin, Skins.color(skin)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            GameEffects.particles(particles, c.maxWidth, c.maxHeight, particleX, particleY),
                            if (levelUp) GameEffects.levelUp(true),
                            if (playing && paused)
                              _overlayCard(
                                icon: Icons.pause_circle_filled_rounded,
                                color: Colors.amber,
                                title: 'PAUSED',
                                subtitle: 'Take a breath. Your game is waiting.',
                                buttonText: 'RESUME GAME',
                                onPressed: resumeGame,
                              ),
                            if (!playing)
                              _overlayCard(
                                icon: score == 0 ? Icons.rocket_launch_rounded : Icons.emoji_events_rounded,
                                color: score == 0 ? Colors.cyanAccent : Colors.amber,
                                title: score == 0 ? 'READY?' : (lives == 0 ? 'GAME OVER' : 'TIME UP'),
                                subtitle: score == 0 ? 'Catch stars. Build combos. Beat your best.' : 'Final Score  •  $score',
                                buttonText: score == 0 ? 'START GAME' : 'PLAY AGAIN',
                                onPressed: startGame,
                                extra: score > 0 ? '🏆 Best $best   •   🔥 $bestCombo× best combo' : null,
                              ),],
                        );
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: .35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11)),
      ]),
    );
  }

  Widget _overlayCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    String? extra,
  }) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallHeight = constraints.maxHeight < 650;

          final cardPadding = isSmallHeight
              ? const EdgeInsets.fromLTRB(18, 16, 18, 14)
              : const EdgeInsets.fromLTRB(24, 26, 24, 22);

          final iconSize = isSmallHeight ? 58.0 : 82.0;
          final actualIconSize = isSmallHeight ? 34.0 : 50.0;
          final titleSize = isSmallHeight ? 23.0 : 28.0;
          final gap = isSmallHeight ? 7.0 : 14.0;
          final buttonVerticalPadding = isSmallHeight ? 11.0 : 15.0;

          return Container(
            constraints: const BoxConstraints(
              maxWidth: 390,
            ),
            margin: EdgeInsets.all(
              isSmallHeight ? 10 : 22,
            ),
            padding: cardPadding,
            decoration: BoxDecoration(
              color: const Color(0xEE0B1330),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: color.withValues(alpha: .42),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: .12),
                  blurRadius: 35,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: .10),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: .24),
                        blurRadius: 25,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: actualIconSize,
                  ),
                ),

                SizedBox(height: gap),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(height: isSmallHeight ? 4 : 7),

                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: isSmallHeight ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xA6FFFFFF),
                    fontSize: isSmallHeight ? 12 : 14,
                  ),
                ),

                if (extra != null) ...[
                  SizedBox(height: isSmallHeight ? 5 : 10),
                  Text(
                    extra,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: isSmallHeight ? 10 : 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                SizedBox(height: isSmallHeight ? 10 : 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPressed,
                    icon: Icon(
                      buttonText == 'RESUME GAME'
                          ? Icons.play_arrow_rounded
                          : Icons.rocket_launch_rounded,
                      size: isSmallHeight ? 18 : 22,
                    ),
                    label: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: isSmallHeight ? 13 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        vertical: buttonVerticalPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    game.cancel();
    audio.dispose();
    super.dispose();
  }
}


class _ArenaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .035)
      ..strokeWidth = 1;
    const gap = 42.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final glow = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: .025)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 45);
    canvas.drawCircle(Offset(size.width * .2, size.height * .18), 90, glow);
    canvas.drawCircle(Offset(size.width * .82, size.height * .72), 120, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
